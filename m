From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: =?UTF-8?Q?nf=5Funregister=5Fnet=5Fhook=3A=20hook=20not=20found!?=
Date: Mon, 28 Dec 2015 21:05:03 +0100
Message-ID: <8312456317d37de2b445bbece288b268@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Running a 4.4.0-rc6 kernel i encountered the warning below.

--
Sander



[   13.740472] ip_tables: (C) 2000-2006 Netfilter Core Team
[   13.936237] iwlwifi 0000:03:00.0: L1 Enabled - LTR Disabled
[   13.945391] iwlwifi 0000:03:00.0: L1 Enabled - LTR Disabled
[   13.947434] iwlwifi 0000:03:00.0: Radio type=0x2-0x1-0x0
[   14.223990] iwlwifi 0000:03:00.0: L1 Enabled - LTR Disabled
[   14.232065] iwlwifi 0000:03:00.0: L1 Enabled - LTR Disabled
[   14.233570] iwlwifi 0000:03:00.0: Radio type=0x2-0x1-0x0
[   14.328141] systemd-logind[2485]: Failed to start user service: 
Unknown unit: user@117.service
[   14.356634] systemd-logind[2485]: New session c1 of user lightdm.
[   14.357320] ------------[ cut here ]------------
[   14.357327] WARNING: CPU: 2 PID: 102 at net/netfilter/core.c:143 
netfilter_net_exit+0x25/0x50()
[   14.357328] nf_unregister_net_hook: hook not found!
[   14.357371] Modules linked in: iptable_security(+) iptable_raw 
iptable_filter ip_tables x_tables input_polldev bnep binfmt_misc nfsd 
auth_rpcgss oid_registry nfs_acl nfs lockd grace fscache sunrpc uvcvideo 
videobuf2_vmalloc iTCO_wdt arc4 videobuf2_memops iTCO_vendor_support 
intel_rapl iosf_mbi videobuf2_v4l2 x86_pkg_temp_thermal intel_powerclamp 
btusb coretemp snd_hda_codec_hdmi iwldvm videobuf2_core btrtl kvm_intel 
v4l2_common mac80211 videodev btbcm snd_hda_codec_conexant btintel media 
kvm snd_hda_codec_generic bluetooth psmouse thinkpad_acpi iwlwifi 
snd_hda_intel pcspkr serio_raw snd_hda_codec nvram cfg80211 snd_hwdep 
snd_hda_core rfkill i2c_i801 lpc_ich snd_pcm mfd_core snd_timer evdev 
snd soundcore shpchp tpm_tis tpm algif_skcipher af_alg crct10dif_pclmul 
crc32_pclmul crc32c_intel aesni_intel
[   14.357380]  ehci_pci sdhci_pci aes_x86_64 glue_helper ehci_hcd 
e1000e lrw ablk_helper sg sdhci cryptd sd_mod ptp mmc_core usbcore 
usb_common pps_core
[   14.357383] CPU: 2 PID: 102 Comm: kworker/u16:3 Tainted: G     U      
     4.4.0-rc6-x220-20151224+ #1
[   14.357384] Hardware name: LENOVO 42912ZU/42912ZU, BIOS 8DET69WW 
(1.39 ) 07/18/2013
[   14.357390] Workqueue: netns cleanup_net
[   14.357393]  ffffffff81a27dfd ffffffff81359c69 ffff88030e7cbd40 
ffffffff81060297
[   14.357395]  ffff88030e820d80 ffff88030e7cbd90 ffffffff81c962d8 
ffffffff81c962e0
[   14.357397]  ffff88030e7cbdf8 ffffffff81060317 ffffffff81a2c010 
ffff880300000018
[   14.357398] Call Trace:
[   14.357405]  [<ffffffff81359c69>] ? dump_stack+0x40/0x57
[   14.357408]  [<ffffffff81060297>] ? warn_slowpath_common+0x77/0xb0
[   14.357410]  [<ffffffff81060317>] ? warn_slowpath_fmt+0x47/0x50
[   14.357416]  [<ffffffff816f9549>] ? mutex_lock+0x9/0x30
[   14.357418]  [<ffffffff81641b35>] ? netfilter_net_exit+0x25/0x50
[   14.357421]  [<ffffffff8160b78e>] ? ops_exit_list.isra.6+0x2e/0x60
[   14.357424]  [<ffffffff8160c3eb>] ? cleanup_net+0x1ab/0x280
[   14.357427]  [<ffffffff81074b33>] ? process_one_work+0x133/0x330
[   14.357429]  [<ffffffff81074d90>] ? worker_thread+0x60/0x470
[   14.357430]  [<ffffffff81074d30>] ? process_one_work+0x330/0x330
[   14.357434]  [<ffffffff81079c0a>] ? kthread+0xca/0xe0
[   14.357436]  [<ffffffff81079b40>] ? 
kthread_create_on_node+0x170/0x170
[   14.357439]  [<ffffffff816fb5cf>] ? ret_from_fork+0x3f/0x70
[   14.357441]  [<ffffffff81079b40>] ? 
kthread_create_on_node+0x170/0x170
[   14.357443] ---[ end trace 9984cc4b0e89f818 ]---
[   14.357443] ------------[ cut here ]------------
[   14.357446] WARNING: CPU: 2 PID: 102 at net/netfilter/core.c:143 
netfilter_net_exit+0x25/0x50()
[   14.357446] nf_unregister_net_hook: hook not found!
[   14.357472] Modules linked in: iptable_security(+) iptable_raw 
iptable_filter ip_tables x_tables input_polldev bnep binfmt_misc nfsd 
auth_rpcgss oid_registry nfs_acl nfs lockd grace fscache sunrpc uvcvideo 
videobuf2_vmalloc iTCO_wdt arc4 videobuf2_memops iTCO_vendor_support 
intel_rapl iosf_mbi videobuf2_v4l2 x86_pkg_temp_thermal intel_powerclamp 
btusb coretemp snd_hda_codec_hdmi iwldvm videobuf2_core btrtl kvm_intel 
v4l2_common mac80211 videodev btbcm snd_hda_codec_conexant btintel media 
kvm snd_hda_codec_generic bluetooth psmouse thinkpad_acpi iwlwifi 
snd_hda_intel pcspkr serio_raw snd_hda_codec nvram cfg80211 snd_hwdep 
snd_hda_core rfkill i2c_i801 lpc_ich snd_pcm mfd_core snd_timer evdev 
snd soundcore shpchp tpm_tis tpm algif_skcipher af_alg crct10dif_pclmul 
crc32_pclmul crc32c_intel aesni_intel
[   14.357478]  ehci_pci sdhci_pci aes_x86_64 glue_helper ehci_hcd 
e1000e lrw ablk_helper sg sdhci cryptd sd_mod ptp mmc_core usbcore 
usb_common pps_core
[   14.357480] CPU: 2 PID: 102 Comm: kworker/u16:3 Tainted: G     U  W   
     4.4.0-rc6-x220-20151224+ #1
[   14.357481] Hardware name: LENOVO 42912ZU/42912ZU, BIOS 8DET69WW 
(1.39 ) 07/18/2013
[   14.357484] Workqueue: netns cleanup_net
[   14.357486]  ffffffff81a27dfd ffffffff81359c69 ffff88030e7cbd40 
ffffffff81060297
[   14.357488]  ffff88030e820db8 ffff88030e7cbd90 ffffffff81c962d8 
ffffffff81c962e0
[   14.357489]  ffff88030e7cbdf8 ffffffff81060317 ffffffff81a2c010 
ffff880300000018
[   14.357490] Call Trace:
[   14.357493]  [<ffffffff81359c69>] ? dump_stack+0x40/0x57
[   14.357495]  [<ffffffff81060297>] ? warn_slowpath_common+0x77/0xb0
[   14.357497]  [<ffffffff81060317>] ? warn_slowpath_fmt+0x47/0x50
[   14.357499]  [<ffffffff816f9549>] ? mutex_lock+0x9/0x30
[   14.357501]  [<ffffffff81641b35>] ? netfilter_net_exit+0x25/0x50
[   14.357504]  [<ffffffff8160b78e>] ? ops_exit_list.isra.6+0x2e/0x60
[   14.357507]  [<ffffffff8160c3eb>] ? cleanup_net+0x1ab/0x280
[   14.357509]  [<ffffffff81074b33>] ? process_one_work+0x133/0x330
[   14.357511]  [<ffffffff81074d90>] ? worker_thread+0x60/0x470
[   14.357512]  [<ffffffff81074d30>] ? process_one_work+0x330/0x330
[   14.357514]  [<ffffffff81079c0a>] ? kthread+0xca/0xe0
[   14.357517]  [<ffffffff81079b40>] ? 
kthread_create_on_node+0x170/0x170
[   14.357519]  [<ffffffff816fb5cf>] ? ret_from_fork+0x3f/0x70
[   14.357521]  [<ffffffff81079b40>] ? 
kthread_create_on_node+0x170/0x170
[   14.357522] ---[ end trace 9984cc4b0e89f819 ]---
[   14.357523] ------------[ cut here ]------------
