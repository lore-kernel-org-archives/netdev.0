From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: ath9k gpio request
Date: Tue, 31 May 2016 13:05:06 +0530
Message-ID: <574D3EAA.3060102@gmail.com>
References: <20160530132225.4d297678@canb.auug.org.au>	<574C4851.9090201@gmail.com> <87fusy3cqx.fsf_-_@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010000090108020101090000"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Miaoqing Pan <miaoqing@codeaurora.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35519 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbcEaMFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 08:05:24 -0400
In-Reply-To: <87fusy3cqx.fsf_-_@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010000090108020101090000
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On Tuesday 31 May 2016 01:01 PM, Kalle Valo wrote:
> (Changing subject to a more descriptive one, was "Re: linux-next: Tree
> for May 30")
>
> Sudip Mukherjee <sudipm.mukherjee@gmail.com> writes:
>
>> Hi All,
>> I have just built and booted with next-20160530 and my dmesg is full
>> of warnings from ath9k. Last kernel tested was v4.6 and there was no
>> problem with that.
>>

<snip>


> The traces look incomplete to me, is there anything more before the
> "Call Trace:" line? Full unedited logs are usually the best.

sure, its attached. those two warnings are recursively going on and 
there is nothing else left in dmesg to see what started it.

Regards
Sudip

--------------010000090108020101090000
Content-Type: text/plain; charset=UTF-8;
 name="dmesg.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="dmesg.txt"

 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffff817d6e92>] ? mutex_lock+0x12/0x2f
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869e9 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffff817d6e92>] ? mutex_lock+0x12/0x2f
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869ea ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869eb ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869ec ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869ed ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869ee ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869ef ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f0 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f1 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f2 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f3 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f4 ]---
------------[ cut here ]------------
WARNING: CPU: 3 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 3 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffff810e6e29>] ? add_timer+0x19/0x20
 [<ffffffff810917fa>] ? __queue_delayed_work+0x8a/0x190
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f5 ]---
------------[ cut here ]------------
WARNING: CPU: 3 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 3 PID: 194 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002c4c3b70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002c4c3bb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffff810e6e29>] ? add_timer+0x19/0x20
 [<ffffffff810917fa>] ? __queue_delayed_work+0x8a/0x190
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f6 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f7 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f8 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc06f621a>] ? fw_domains_get_with_thread_status+0x1a/0x20 [i915=
]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869f9 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc06f621a>] ? fw_domains_get_with_thread_status+0x1a/0x20 [i915=
]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869fa ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869fb ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869fc ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869fd ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869fe ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a52869ff ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a00 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a01 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a02 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2776 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000ad800000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a03 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2796 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000aec00000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a04 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a05 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a06 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 2 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a07 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 2 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a08 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a09 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a0a ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a0b ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a0c ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a0d ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a0e ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a0f ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a10 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a11 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a12 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a13 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a14 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a15 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a16 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a17 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a18 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a19 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a1a ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a1b ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a1c ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a1d ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a1e ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a1f ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a20 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a21 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a22 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a23 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a24 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a25 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a26 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a27 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a28 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 1 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a29 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 1 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a2a ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 2 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffff817d6e92>] ? mutex_lock+0x12/0x2f
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a2b ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 2 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffff817d6e92>] ? mutex_lock+0x12/0x2f
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a2c ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a2d ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a2e ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a2f ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a30 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a31 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a32 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a33 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b3041>] ieee80211_scan_work+0x161/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a34 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a35 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb70 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fbb0 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffffc05d9b7e>] ? ieee80211_wake_queues_by_reason+0x8e/0xa0 [mac802=
11]
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b31a6>] ieee80211_scan_work+0x2c6/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a36 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2732 a=
th9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 2 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fb68 ffffffff8107a331 00000aac429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc09582b3>] ath9k_hw_gpio_request+0x303/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffff81091312>] ? __queue_work+0x142/0x420
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b1f79>] __ieee80211_scan_completed+0xd9/0x3b0 [mac80211]
 [<ffffffff810b0035>] ? put_prev_entity+0x35/0x730
 [<ffffffffc05b2f3a>] ieee80211_scan_work+0x5a/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a37 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2739 a=
th9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 2 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: phy0 ieee80211_scan_work [mac80211]
 0000000000000000 ffff88002cb7fb28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fb68 ffffffff8107a331 00000ab3429c4018
 ffff8801429c4018 000000000000000b 0000000000000000 0000000000023f60
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc095801f>] ath9k_hw_gpio_request+0x6f/0x320 [ath9k_hw]
 [<ffffffffc095ac24>] ath9k_hw_reset+0xfe4/0x12e0 [ath9k_hw]
 [<ffffffffc03d45d4>] ath_reset_internal+0x104/0x1f0 [ath9k]
 [<ffffffffc03d46fd>] ath_reset+0x3d/0x60 [ath9k]
 [<ffffffffc03dd1c6>] ath_chanctx_set_channel+0x1b6/0x300 [ath9k]
 [<ffffffffc03d36b6>] ath9k_config+0xc6/0x1f0 [ath9k]
 [<ffffffff81091312>] ? __queue_work+0x142/0x420
 [<ffffffffc05a7923>] ieee80211_hw_config+0x63/0x350 [mac80211]
 [<ffffffffc05b1f79>] __ieee80211_scan_completed+0xd9/0x3b0 [mac80211]
 [<ffffffff810b0035>] ? put_prev_entity+0x35/0x730
 [<ffffffffc05b2f3a>] ieee80211_scan_work+0x5a/0x480 [mac80211]
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a38 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2776 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000ad800000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a39 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2796 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 0 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000aec00000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a3a ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2776 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 1 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000ad800000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a3b ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2796 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 1 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000aec00000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a3c ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2776 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 1 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000ad800000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a3d ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2796 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 1 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000aec00000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a3e ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2776 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 1 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000ad800000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a3f ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 196 at ../drivers/net/wireless/ath/ath9k/hw.c:2796 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k ath9k_comm=
on ath9k_hw i915 ath mac80211 intel_rapl x86_pkg_temp_thermal bnep intel_=
powerclamp rfcomm bluetooth cfg80211 coretemp kvm_intel kvm drm_kms_helpe=
r drm uvcvideo snd_hda_codec_hdmi videobuf2_vmalloc snd_hda_codec_realtek=
 snd_hda_codec_generic videobuf2_memops videobuf2_v4l2 snd_hda_intel vide=
obuf2_core snd_hda_codec videodev snd_hda_core media snd_hwdep irqbypass =
snd_pcm crct10dif_pclmul crc32_pclmul ghash_clmulni_intel snd_seq_midi ae=
sni_intel snd_seq_midi_event snd_rawmidi aes_x86_64 snd_seq sparse_keymap=
 lrw snd_seq_device gf128mul snd_timer glue_helper ablk_helper rtsx_pci_m=
s i2c_algo_bit fb_sys_fops snd syscopyarea memstick cryptd mei_me sysfill=
rect sysimgblt joydev dm_multipath serio_raw mei soundcore video dell_smo=
8800 shpchp lpc_ich mac_hid wmi rtsx_pci_sdmmc psmouse r8169 rtsx_pci ahc=
i libahci mii [last unloaded: parport]
CPU: 1 PID: 196 Comm: kworker/u16:6 Tainted: G        W       4.7.0-rc1-n=
ext-20160530 #4
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cb7fd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cb7fd68 ffffffff8107a331 00000aec00000086
 ffff8801429c4018 000000000000000b ffff880147000720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0956a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc03d03e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc05c4b53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc049d65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 27eb5094a5286a40 ]---

--------------010000090108020101090000--
