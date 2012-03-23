#encoding: UTF-8
#==============================================================================
# �Scene_Title
#------------------------------------------------------------------------------
# �title
#==============================================================================
require_relative 'scene'
require_relative 'widget_inputbox'
require_relative 'window_title'
BGM = 'title.ogg'
class Scene_Title < Scene
  def start
    WM::set_caption("MyCard", "MyCard")
    title = Dir.glob("graphics/titles/title_*.*")
    title = title[rand(title.size)]
    @background = Surface.load(title).display_format
    Surface.blit(@background,0,0,0,0,$screen,0,0)
    @command_window = Window_Title.new(title["left"] ? 200 : title["right"] ? 600 : 400, 300)
    #logo = Surface.load("graphics/system/logo.png")
    #@logo_window = Window.new(@command_window.x-(logo.w-@command_window.width)/2,150,logo.w,logo.h)
    #@logo_window.contents = logo
    #$screen.update_rect(0,0,0,0)
    @decision_se = Mixer::Wave.load("audio/se/decision.ogg")
    
    super
    
  end
  def clear(x,y,width,height)
    Surface.blit(@background,x,y,width,height,$screen,x,y)
  end
  def determine
    return unless @command_window.index
    Mixer.play_channel(-1,@decision_se,0)
    case @command_window.index
    when 0
      require_relative 'scene_login'
      $scene = Scene_Login.new
    when 1
      #require_relative 'scene_single'
      require_relative 'widget_msgbox'
      Widget_Msgbox.new("mycard", "功能未实现", :ok => "确定")
      #Scene_Single.new
    when 2
      require_relative 'widget_msgbox'
      require_relative 'scene_login'
      Widget_Msgbox.new("编辑卡组", "\"导入\"导入已有卡组，\"编辑\"启动ygocore", :import => "导入", :edit => "编辑") do |button|
        case button 
        when:import
          require_relative 'dialog'
          file = Dialog.get_open_file("导入卡组", "ygocore卡组 (*.ydk)"=>"*.ydk")#"所有支持的卡组 (*.txt;*.deck;*.ydk)"=>"*.ydk;*.txt;*.deck","ygocore卡组 (*.ydk)"=>"*.ydk", "NBX/iDuel/狐查卡组 (*.txt)" => "*.txt", "图形组卡器卡组 (*.deck)"=>"*.deck")
          if !file.empty?
            open(file) do |src|
              Dir.mkdir "ygocore/deck" unless File.directory?("ygocore/deck")
              open("ygocore/deck/#{File.basename(file)}", 'w') do |dest|
                dest.write src.read
              end
              Widget_Msgbox.new("导入卡组", "导入卡组完成", :ok => "确定")
            end rescue Widget_Msgbox.new("导入卡组", "导入卡组失败", :ok => "确定")
          end
        when :edit
          load 'lib/ygocore/game.rb' #TODO:不规范啊不规范
          if !Update.images.empty?
            Widget_Msgbox.new("加入房间", "卡图正在下载中，可能显示不出部分卡图", :ok => "确定"){Ygocore.run_ygocore(:deck)}
          else
            Ygocore.run_ygocore(:deck)
          end
        end
      end
      #require_relative 'scene_deck'
      #Scene_Deck.new
    when 3
      require_relative 'scene_config'
      $scene = Scene_Config.new
    when 4
      $scene = nil
    end
  end
  def terminate
    @command_window.destroy
    @background.destroy
    super
  end
end

