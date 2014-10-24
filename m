From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: [PATCH V3.18] rtlwifi: Add check for get_btc_status callback
Date: Fri, 24 Oct 2014 04:09:40 +0200
Message-ID: <1414116580.23080.10.camel@marge.simpson.net>
References: <1414081629-23002-1-git-send-email-Larry.Finger@lwfinger.net>
	 <1414087731.5231.19.camel@marge.simpson.net>
	 <5449478B.4070908@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	troy_tan@realsil.com.cn, netdev@vger.kernel.org,
	Murilo Opsfelder Araujo <mopsfelder@gmail.com>,
	Thadeu Cascardo <cascardo@cascardo.eti.br>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:63610 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751507AbaJXCJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 22:09:45 -0400
In-Reply-To: <5449478B.4070908@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-23 at 13:23 -0500, Larry Finger wrote:

> I know "rtl8192se:rtl92se_get_desc(): ERR rxdesc :4 not process" mess=
ages will=20
> be fixed by the attached patch. Please send the logs after this is ap=
plied.

Both applied.

[   17.717226] cfg80211: World regulatory domain updated:
[   17.719760] cfg80211:  DFS Master region: unset
[   17.719801] cfg80211:   (start_freq - end_freq @ bandwidth), (max_an=
tenna_gain, max_eirp), (dfs_cac_time)
[   17.724656] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   17.727087] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   17.729422] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   17.731592] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   17.733702] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (30=
0 mBi, 2000 mBm), (N/A)
[   17.858132] input: HDA Digital PCBeep as /devices/pci0000:00/0000:00=
:1b.0/sound/card0/hdaudioC0D0/input13
[   17.861052] input: HDA Intel Mic as /devices/pci0000:00/0000:00:1b.0=
/sound/card0/input14
[   17.863153] input: HDA Intel Headphone as /devices/pci0000:00/0000:0=
0:1b.0/sound/card0/input15
[   17.865356] input: HDA Intel HDMI/DP,pcm=3D3 as /devices/pci0000:00/=
0000:00:1b.0/sound/card0/input16
[   18.259078] toshiba_acpi: Unknown key 401
[   18.661507] Adding 2096476k swap on /dev/sda2.  Priority:-1 extents:=
1 across:2096476k FS
[   18.984217] rtl8192se 0000:08:00.0: enabling device (0000 -> 0003)
[   19.025036] rtl8192se: FW Power Save off (module option)
[   19.027195] rtl8192se: Driver for Realtek RTL8192SE/RTL8191SE
[   19.027195] Loading firmware rtlwifi/rtl8192sefw.bin
[   19.095134] ieee80211 phy0: Selected rate control algorithm 'rtl_rc'
[   19.152305] ------------[ cut here ]------------
[   19.154367] WARNING: CPU: 0 PID: 59 at fs/sysfs/dir.c:31 sysfs_warn_=
dup+0x68/0x80()
[   19.156445] sysfs: cannot create duplicate filename '/devices/pci000=
0:00/0000:00:1c.5/0000:08:00.0/ieee80211/phy0'
[   19.158562] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi mac802=
11 snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_codec_generic uvcv=
ideo btusb videobuf2_core coretemp snd_hda_intel snd_hda_controller snd=
_hda_codec iTCO_wdt iTCO_vendor_support bluetooth cfg80211 v4l2_common =
snd_hwdep microcode snd_pcm videodev lpc_ich snd_seq serio_raw snd_time=
r joydev i2c_i801 videobuf2_vmalloc videobuf2_memops mfd_core snd_seq_d=
evice toshiba_acpi sparse_keymap rfkill battery ac snd wmi toshiba_blue=
tooth toshiba_haps soundcore acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   19.170633] CPU: 0 PID: 59 Comm: kworker/0:3 Not tainted 3.18.0-mast=
er #52
[   19.173036] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   19.175634] Workqueue: events request_firmware_work_func
[   19.178247]  0000000000000009 ffff8800379d7a98 ffffffff815878e0 0000=
000000000001
[   19.180947]  ffff8800379d7ae8 ffff8800379d7ad8 ffffffff8104c801 0000=
0000000035e0
[   19.183573]  ffff88003706e000 ffff8800aff86d80 ffff8800b0093d48 ffff=
88013b027098
[   19.186231] Call Trace:
[   19.188885]  [<ffffffff815878e0>] dump_stack+0x46/0x58
[   19.191545]  [<ffffffff8104c801>] warn_slowpath_common+0x81/0xa0
[   19.194173]  [<ffffffff8104c866>] warn_slowpath_fmt+0x46/0x50
[   19.196707]  [<ffffffff811d06c8>] ? kernfs_path+0x48/0x60
[   19.199138]  [<ffffffff811d3b48>] sysfs_warn_dup+0x68/0x80
[   19.201587]  [<ffffffff811d3bee>] sysfs_create_dir_ns+0x8e/0xa0
[   19.204057]  [<ffffffff81286879>] kobject_add_internal+0xc9/0x400
[   19.206495]  [<ffffffff81286fe0>] kobject_add+0x60/0xb0
[   19.208938]  [<ffffffff8158c226>] ? mutex_lock+0x16/0x37
[   19.211321]  [<ffffffff81380d54>] device_add+0x104/0x600
[   19.213692]  [<ffffffff8114b98e>] ? lazy_max_pages+0x1e/0x30
[   19.216100]  [<ffffffffa02e9d0d>] wiphy_register+0x3fd/0x710 [cfg802=
11]
[   19.218504]  [<ffffffff8114d352>] ? __vunmap+0xc2/0x110
[   19.220957]  [<ffffffffa0457cfc>] ? ieee80211_register_hw+0x1ec/0x9a=
0 [mac80211]
[   19.223447]  [<ffffffffa0457e78>] ieee80211_register_hw+0x368/0x9a0 =
[mac80211]
[   19.225916]  [<ffffffffa050a26b>] rtl92se_fw_cb+0xab/0x1d0 [rtl8192s=
e]
[   19.228362]  [<ffffffff81393d80>] request_firmware_work_func+0x30/0x=
60
[   19.230779]  [<ffffffff8106270d>] process_one_work+0x14d/0x3d0
[   19.233167]  [<ffffffff81062ab1>] worker_thread+0x121/0x480
[   19.235498]  [<ffffffff81062990>] ? process_one_work+0x3d0/0x3d0
[   19.237861]  [<ffffffff81067319>] kthread+0xc9/0xe0
[   19.240213]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   19.242534]  [<ffffffff8158e26c>] ret_from_fork+0x7c/0xb0
[   19.244830]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   19.247125] ---[ end trace 0734244a9269eff8 ]---
[   19.249416] ------------[ cut here ]------------
[   19.251626] WARNING: CPU: 0 PID: 59 at lib/kobject.c:240 kobject_add=
_internal+0x294/0x400()
[   19.253876] kobject_add_internal failed for phy0 with -EEXIST, don't=
 try to register things with the same name in the same directory.
[   19.256197] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi mac802=
11 snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_codec_generic uvcv=
ideo btusb videobuf2_core coretemp snd_hda_intel snd_hda_controller snd=
_hda_codec iTCO_wdt iTCO_vendor_support bluetooth cfg80211 v4l2_common =
snd_hwdep microcode snd_pcm videodev lpc_ich snd_seq serio_raw snd_time=
r joydev i2c_i801 videobuf2_vmalloc videobuf2_memops mfd_core snd_seq_d=
evice toshiba_acpi sparse_keymap rfkill battery ac snd wmi toshiba_blue=
tooth toshiba_haps soundcore acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   19.269327] CPU: 0 PID: 59 Comm: kworker/0:3 Tainted: G        W    =
  3.18.0-master #52
[   19.271976] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   19.274674] Workqueue: events request_firmware_work_func
[   19.277301]  0000000000000009 ffff8800379d7af8 ffffffff815878e0 0000=
000000000001
[   19.279875]  ffff8800379d7b48 ffff8800379d7b38 ffffffff8104c801 ffff=
8800379d7b38
[   19.282376]  ffff880137730350 00000000ffffffef ffff880036a9c940 ffff=
88013b027098
[   19.284844] Call Trace:
[   19.287151]  [<ffffffff815878e0>] dump_stack+0x46/0x58
[   19.289474]  [<ffffffff8104c801>] warn_slowpath_common+0x81/0xa0
[   19.291751]  [<ffffffff8104c866>] warn_slowpath_fmt+0x46/0x50
[   19.293979]  [<ffffffff81286a44>] kobject_add_internal+0x294/0x400
[   19.296192]  [<ffffffff81286fe0>] kobject_add+0x60/0xb0
[   19.298381]  [<ffffffff8158c226>] ? mutex_lock+0x16/0x37
[   19.300578]  [<ffffffff81380d54>] device_add+0x104/0x600
[   19.302734]  [<ffffffff8114b98e>] ? lazy_max_pages+0x1e/0x30
[   19.304909]  [<ffffffffa02e9d0d>] wiphy_register+0x3fd/0x710 [cfg802=
11]
[   19.307110]  [<ffffffff8114d352>] ? __vunmap+0xc2/0x110
[   19.309305]  [<ffffffffa0457cfc>] ? ieee80211_register_hw+0x1ec/0x9a=
0 [mac80211]
[   19.311512]  [<ffffffffa0457e78>] ieee80211_register_hw+0x368/0x9a0 =
[mac80211]
[   19.313767]  [<ffffffffa050a26b>] rtl92se_fw_cb+0xab/0x1d0 [rtl8192s=
e]
[   19.315998]  [<ffffffff81393d80>] request_firmware_work_func+0x30/0x=
60
[   19.318260]  [<ffffffff8106270d>] process_one_work+0x14d/0x3d0
[   19.320501]  [<ffffffff81062ab1>] worker_thread+0x121/0x480
[   19.322732]  [<ffffffff81062990>] ? process_one_work+0x3d0/0x3d0
[   19.324987]  [<ffffffff81067319>] kthread+0xc9/0xe0
[   19.327246]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   19.329517]  [<ffffffff8158e26c>] ret_from_fork+0x7c/0xb0
[   19.331757]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   19.334039] ---[ end trace 0734244a9269eff9 ]---
[   19.336275] rtl8192se:rtl92se_fw_cb():<0-0> Can't register mac80211 =
hw
[   20.108822] EXT4-fs (sda1): mounted filesystem with ordered data mod=
e. Opts: acl
[   24.761182] BUG: unable to handle kernel NULL pointer dereference at=
           (null)
[   24.762764] IP: [<          (null)>]           (null)
[   24.764106] PGD 0=20
[   24.764106] Oops: 0010 [#1] SMP=20
[   24.764106] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi mac802=
11 snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_codec_generic uvcv=
ideo btusb videobuf2_core coretemp snd_hda_intel snd_hda_controller snd=
_hda_codec iTCO_wdt iTCO_vendor_support bluetooth cfg80211 v4l2_common =
snd_hwdep microcode snd_pcm videodev lpc_ich snd_seq serio_raw snd_time=
r joydev i2c_i801 videobuf2_vmalloc videobuf2_memops mfd_core snd_seq_d=
evice toshiba_acpi sparse_keymap rfkill battery ac snd wmi toshiba_blue=
tooth toshiba_haps soundcore acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   24.764106] CPU: 1 PID: 54 Comm: kworker/1:2 Tainted: G        W    =
  3.18.0-master #52
[   24.764106] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   24.764106] Workqueue: rtl92s_pci rtl_watchdog_wq_callback [rtlwifi]
[   24.764106] task: ffff88013614c350 ti: ffff880136150000 task.ti: fff=
f880136150000
[   24.764106] RIP: 0010:[<0000000000000000>]  [<          (null)>]    =
       (null)
[   24.764106] RSP: 0018:ffff880136153d80  EFLAGS: 00010293
[   24.764106] RAX: ffffffffa05103c0 RBX: ffff8801377319c0 RCX: 0000000=
000000000
[   24.764106] RDX: 0000000000000001 RSI: 000000000000005d RDI: ffff880=
137730620
[   24.764106] RBP: ffff880136153df8 R08: ffff88013fd12380 R09: 0000000=
000000001
[   24.764106] R10: 0000000000000002 R11: 0000000000000293 R12: ffff880=
137730620
[   24.764106] R13: 0000000000000000 R14: 0000000000000000 R15: 0000000=
000000000
[   24.764106] FS:  0000000000000000(0000) GS:ffff88013fd00000(0000) kn=
lGS:0000000000000000
[   24.764106] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   24.764106] CR2: 0000000000000000 CR3: 000000013b249000 CR4: 0000000=
0000407e0
[   24.764106] Stack:
[   24.764106]  ffffffffa051e51e ffff88013fd12b00 0000000000000000 ffff=
88013fd12b00
[   24.764106]  0000000000000000 0000000000000000 0000000000000000 0000=
000000000000
[   24.764106]  0000000000000000 ffff880136153e38 ffff880137731be0 ffff=
880136126b80
[   24.764106] Call Trace:
[   24.764106]  [<ffffffffa051e51e>] ? rtl_watchdog_wq_callback+0xfe/0x=
420 [rtlwifi]
[   24.764106]  [<ffffffff8106270d>] process_one_work+0x14d/0x3d0
[   24.764106]  [<ffffffff81062ab1>] worker_thread+0x121/0x480
[   24.764106]  [<ffffffff81062990>] ? process_one_work+0x3d0/0x3d0
[   24.764106]  [<ffffffff81067319>] kthread+0xc9/0xe0
[   24.764106]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   24.764106]  [<ffffffff8158e26c>] ret_from_fork+0x7c/0xb0
[   24.764106]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   24.764106] Code:  Bad RIP value.
[   24.764106] RIP  [<          (null)>]           (null)
[   24.764106]  RSP <ffff880136153d80>
[   24.764106] CR2: 0000000000000000
[   24.764106] ---[ end trace 0734244a9269effa ]---
[   24.855146] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   24.857620] BUG: unable to handle kernel paging request at fffffffff=
fffffd8
[   24.859873] IP: [<ffffffff810678f1>] kthread_data+0x11/0x20
[   24.861381] PGD 1a16067 PUD 1a18067 PMD 0=20
[   24.861381] Oops: 0000 [#2] SMP=20
[   24.861381] Modules linked in: arc4 rtl8192se rtl_pci rtlwifi mac802=
11 snd_hda_codec_hdmi snd_hda_codec_conexant snd_hda_codec_generic uvcv=
ideo btusb videobuf2_core coretemp snd_hda_intel snd_hda_controller snd=
_hda_codec iTCO_wdt iTCO_vendor_support bluetooth cfg80211 v4l2_common =
snd_hwdep microcode snd_pcm videodev lpc_ich snd_seq serio_raw snd_time=
r joydev i2c_i801 videobuf2_vmalloc videobuf2_memops mfd_core snd_seq_d=
evice toshiba_acpi sparse_keymap rfkill battery ac snd wmi toshiba_blue=
tooth toshiba_haps soundcore acpi_cpufreq sg autofs4 i915 drm_kms_helpe=
r drm i2c_algo_bit thermal video processor thermal_sys button scsi_dh_r=
dac scsi_dh_alua scsi_dh_emc scsi_dh_hp_sw scsi_dh netconsole atl1c
[   24.861381] CPU: 1 PID: 54 Comm: kworker/1:2 Tainted: G      D W    =
  3.18.0-master #52
[   24.861381] Hardware name: TOSHIBA =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD/=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD, BIOS V1.70    09/29/2009
[   24.861381] task: ffff88013614c350 ti: ffff880136150000 task.ti: fff=
f880136150000
[   24.861381] RIP: 0010:[<ffffffff810678f1>]  [<ffffffff810678f1>] kth=
read_data+0x11/0x20
[   24.861381] RSP: 0018:ffff880136153990  EFLAGS: 00010092
[   24.861381] RAX: 0000000000000000 RBX: 0000000000000001 RCX: 0000000=
171a414dc
[   24.861381] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff880=
13614c350
[   24.861381] RBP: ffff8801361539a8 R08: ffff88013614fcd0 R09: 0000000=
0000003d9
[   24.861381] R10: 000000000000bc00 R11: 0000000000008ddc R12: ffff880=
13fd12b00
[   24.861381] R13: 0000000000000001 R14: 0000000000000000 R15: ffff880=
13614c350
[   24.861381] FS:  0000000000000000(0000) GS:ffff88013fd00000(0000) kn=
lGS:0000000000000000
[   24.861381] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   24.861381] CR2: 0000000000000028 CR3: 0000000035eba000 CR4: 0000000=
0000407e0
[   24.861381] Stack:
[   24.861381]  ffffffff81063145 ffff8801361539a8 ffff88013614c350 ffff=
880136153a18
[   24.861381]  ffffffff8158a1ae ffff88013614c350 0000000000012b00 ffff=
880136153fd8
[   24.861381]  0000000000012b00 ffff880136153a08 ffff88013614c350 ffff=
88013614c350
[   24.861381] Call Trace:
[   24.861381]  [<ffffffff81063145>] ? wq_worker_sleeping+0x15/0xa0
[   24.861381]  [<ffffffff8158a1ae>] __schedule+0x53e/0x810
[   24.861381]  [<ffffffff8158a4a9>] schedule+0x29/0x70
[   24.861381]  [<ffffffff8104dfa2>] do_exit+0x6a2/0x9e0
[   24.861381]  [<ffffffff8100645e>] oops_end+0x8e/0xd0
[   24.861381]  [<ffffffff815829aa>] no_context+0x248/0x298
[   24.861381]  [<ffffffff81582a67>] __bad_area_nosemaphore+0x6d/0x1c6
[   24.861381]  [<ffffffff81582bd3>] bad_area_nosemaphore+0x13/0x15
[   24.861381]  [<ffffffff8103d67c>] __do_page_fault+0x9c/0x530
[   24.861381]  [<ffffffff812843c0>] ? cpumask_next_and+0x30/0x50
[   24.861381]  [<ffffffff8107a24e>] ? load_balance+0x23e/0x830
[   24.861381]  [<ffffffff8103db1c>] do_page_fault+0xc/0x10
[   24.861381]  [<ffffffff8158fe22>] page_fault+0x22/0x30
[   24.861381]  [<ffffffffa051e51e>] ? rtl_watchdog_wq_callback+0xfe/0x=
420 [rtlwifi]
[   24.861381]  [<ffffffff8106270d>] process_one_work+0x14d/0x3d0
[   24.861381]  [<ffffffff81062ab1>] worker_thread+0x121/0x480
[   24.861381]  [<ffffffff81062990>] ? process_one_work+0x3d0/0x3d0
[   24.861381]  [<ffffffff81067319>] kthread+0xc9/0xe0
[   24.861381]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   24.861381]  [<ffffffff8158e26c>] ret_from_fork+0x7c/0xb0
[   24.861381]  [<ffffffff81067250>] ? kthread_create_on_node+0x180/0x1=
80
[   24.861381] Code: 48 89 e5 5d 48 8b 40 c8 48 c1 e8 02 83 e0 01 c3 66=
 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 48 8b 87 60 04 00 00 55 48 8=
9 e5 5d <48> 8b 40 d8 c3 66 2e 0f 1f 84 00 00 00 00 00 66 66 66 66 90 5=
5=20
[   24.861381] RIP  [<ffffffff810678f1>] kthread_data+0x11/0x20
[   24.861381]  RSP <ffff880136153990>
[   24.861381] CR2: ffffffffffffffd8
[   24.861381] ---[ end trace 0734244a9269effb ]---
[   24.861381] Fixing recursive fault but reboot is needed!
[   24.861381] Kernel panic - not syncing: Watchdog detected hard LOCKU=
P on cpu 1
[   24.861381] Shutting down cpus with NMI
[   24.861381] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation r=
ange: 0xffffffff80000000-0xffffffff9fffffff)
[   24.861381] drm_kms_helper: panic occurred, switching back to text c=
onsole
[   24.861381] Rebooting in 60 seconds..
