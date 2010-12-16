From: Tomas Winkler <tomasw@gmail.com>
Subject: BUG: while bridging Ethernet and wireless device:
Date: Thu, 16 Dec 2010 14:11:33 +0200
Message-ID: <AANLkTikYvBspVmAZ0DCMXJ-3WxkotwX+n8NpTtM+97_i@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44364 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120Ab0LPMLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 07:11:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will be happy if someone can give me some more insight. (kernel 2.6.37-rc5)
Thanks
Tomas

Dec 15 14:36:41 User-PC kernel: [175576.120287] ------------[ cut here
]------------
Dec 15 14:36:41 User-PC kernel: [175576.120452] kernel BUG at
include/linux/skbuff.h:1178!
Dec 15 14:36:41 User-PC kernel: [175576.120609] invalid opcode: 0000 [#1] SMP
Dec 15 14:36:41 User-PC kernel: [175576.120749] last sysfs file:
/sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/uevent
Dec 15 14:36:41 User-PC kernel: [175576.121035] Modules linked in:
oprofile binfmt_misc bridge stp llc parport_pc ppdev arc4 iwlagn
snd_hda_codec_realtek iwlcore i915 snd_hda_intel mac80211 joydev
snd_hda_codec snd_hwdep snd_pcm snd_seq_midi drm_kms_helper
snd_rawmidi drm snd_seq_midi_event snd_seq snd_timer snd_seq_device
cfg80211 eeepc_wmi usbhid psmouse intel_agp i2c_algo_bit intel_gtt
uvcvideo agpgart videodev sparse_keymap snd shpchp v4l1_compat lp hid
video serio_raw soundcore output snd_page_alloc ahci libahci atl1c
Dec 15 14:36:41 User-PC kernel: [175576.122712]
Dec 15 14:36:41 User-PC kernel: [175576.122769] Pid: 0, comm:
kworker/0:0 Tainted: G        W   2.6.37-rc5-wl+ #3 1015PE/1016P
Dec 15 14:36:41 User-PC kernel: [175576.123012] EIP: 0060:[<f83edd65>]
EFLAGS: 00010283 CPU: 1
Dec 15 14:36:41 User-PC kernel: [175576.123193] EIP is at
br_multicast_rcv+0xc95/0xe1c [bridge]
Dec 15 14:36:41 User-PC kernel: [175576.123362] EAX: 0000001c EBX:
f5626318 ECX: 00000000 EDX: 00000000
Dec 15 14:36:41 User-PC kernel: [175576.123550] ESI: ec512262 EDI:
f5626180 EBP: f60b5ca0 ESP: f60b5bd8
Dec 15 14:36:41 User-PC kernel: [175576.123737]  DS: 007b ES: 007b FS:
00d8 GS: 00e0 SS: 0068
Dec 15 14:36:41 User-PC kernel: [175576.123902] Process kworker/0:0
(pid: 0, ti=f60b4000 task=f60a8000 task.ti=f60b0000)
Dec 15 14:36:41 User-PC kernel: [175576.124137] Stack:
Dec 15 14:36:41 User-PC kernel: [175576.124181]  ec556500 f6d06800
f60b5be8 c01087d8 ec512262 00000030 00000024 f5626180
Dec 15 14:36:41 User-PC kernel: [175576.124181]  f572c200 ef463440
f5626300 3affffff f6d06dd0 e60766a4 000000c4 f6d06860
Dec 15 14:36:41 User-PC kernel: [175576.124181]  ffffffff ec55652c
00000001 f6d06844 f60b5c64 c0138264 c016e451 c013e47d
Dec 15 14:36:41 User-PC kernel: [175576.124181] Call Trace:
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c01087d8>] ?
sched_clock+0x8/0x10
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0138264>] ?
enqueue_entity+0x174/0x440
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c016e451>] ?
sched_clock_cpu+0x131/0x190
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c013e47d>] ?
select_task_rq_fair+0x2ad/0x730
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0524fc1>] ?
nf_iterate+0x71/0x90
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e4914>] ?
br_handle_frame_finish+0x184/0x220 [bridge]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e4790>] ?
br_handle_frame_finish+0x0/0x220 [bridge]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e46e9>] ?
br_handle_frame+0x189/0x230 [bridge]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e4790>] ?
br_handle_frame_finish+0x0/0x220 [bridge]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f83e4560>] ?
br_handle_frame+0x0/0x230 [bridge]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04ff026>] ?
__netif_receive_skb+0x1b6/0x5b0
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04f7a30>] ?
skb_copy_bits+0x110/0x210
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0503a7f>] ?
netif_receive_skb+0x6f/0x80
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f82cb74c>] ?
ieee80211_deliver_skb+0x8c/0x1a0 [mac80211]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f82cc836>] ?
ieee80211_rx_handlers+0xeb6/0x1aa0 [mac80211]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04ff1f0>] ?
__netif_receive_skb+0x380/0x5b0
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c016e242>] ?
sched_clock_local+0xb2/0x190
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c012b688>] ?
default_spin_lock_flags+0x8/0x10
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d83df>] ?
_raw_spin_lock_irqsave+0x2f/0x50
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f82cd621>] ?
ieee80211_prepare_and_rx_handle+0x201/0xa90 [mac80211]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f82ce154>] ?
ieee80211_rx+0x2a4/0x830 [mac80211]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f815a8d6>] ?
iwl_update_stats+0xa6/0x2a0 [iwlcore]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f8499212>] ?
iwlagn_rx_reply_rx+0x292/0x3b0 [iwlagn]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d83df>] ?
_raw_spin_lock_irqsave+0x2f/0x50
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f8483697>] ?
iwl_rx_handle+0xe7/0x350 [iwlagn]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<f8486ab7>] ?
iwl_irq_tasklet+0xf7/0x5c0 [iwlagn]
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c01aece1>] ?
__rcu_process_callbacks+0x201/0x2d0
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0150d05>] ?
tasklet_action+0xc5/0x100
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0150a07>] ?
__do_softirq+0x97/0x1d0
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d910c>] ?
nmi_stack_correct+0x2f/0x34
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0150970>] ?
__do_softirq+0x0/0x1d0
Dec 15 14:36:41 User-PC kernel: [175576.124181]  <IRQ>
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c01508f5>] ?
irq_exit+0x65/0x70
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05df062>] ? do_IRQ+0x52/0xc0
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c01036b0>] ?
common_interrupt+0x30/0x38
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c03a1fc2>] ?
intel_idle+0xc2/0x160
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04daebb>] ?
cpuidle_idle_call+0x6b/0x100
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0101dea>] ?
cpu_idle+0x8a/0xf0
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d2702>] ?
start_secondary+0x1e8/0x1ee
Dec 15 14:36:41 User-PC kernel: [175576.124181] Code: ff ff ff be ea
ff ff ff 8b 82 b0 00 00 00 e9 fb f5 ff ff 89 c8 e8 4c dc ff ff 85 c0
89 c6 0f 84 9b f5 ff ff 66 90 e9 be fe ff ff <0f> 0b eb fe c7 47 20 01
00 00 00 8b 43 04 89 c2 81 e2 ff ff ff
Dec 15 14:36:41 User-PC kernel: [175576.124181] EIP: [<f83edd65>]
br_multicast_rcv+0xc95/0xe1c [bridge] SS:ESP 0068:f60b5bd8
Dec 15 14:36:41 User-PC kernel: [175576.124181] BUG: scheduling while
atomic: kworker/0:0/0/0x10000100
Dec 15 14:36:41 User-PC kernel: [175576.124181] Modules linked in:
oprofile binfmt_misc bridge stp llc parport_pc ppdev arc4 iwlagn
snd_hda_codec_realtek iwlcore i915 snd_hda_intel mac80211 joydev
snd_hda_codec snd_hwdep snd_pcm snd_seq_midi drm_kms_helper
snd_rawmidi drm snd_seq_midi_event snd_seq snd_timer snd_seq_device
cfg80211 eeepc_wmi usbhid psmouse intel_agp i2c_algo_bit intel_gtt
uvcvideo agpgart videodev sparse_keymap snd shpchp v4l1_compat lp hid
video serio_raw soundcore output snd_page_alloc ahci libahci atl1c
Dec 15 14:36:41 User-PC kernel: [175576.124181] Modules linked in:
oprofile binfmt_misc bridge stp llc parport_pc ppdev arc4 iwlagn
snd_hda_codec_realtek iwlcore i915 snd_hda_intel mac80211 joydev
snd_hda_codec snd_hwdep snd_pcm snd_seq_midi drm_kms_helper
snd_rawmidi drm snd_seq_midi_event snd_seq snd_timer snd_seq_device
cfg80211 eeepc_wmi usbhid psmouse intel_agp i2c_algo_bit intel_gtt
uvcvideo agpgart videodev sparse_keymap snd shpchp v4l1_compat lp hid
video serio_raw soundcore output snd_page_alloc ahci libahci atl1c
Dec 15 14:36:41 User-PC kernel: [175576.124181]
Dec 15 14:36:41 User-PC kernel: [175576.124181] Pid: 0, comm:
kworker/0:0 Tainted: G        W   2.6.37-rc5-wl+ #3 1015PE/1016P
Dec 15 14:36:41 User-PC kernel: [175576.124181] EIP: 0060:[<c03a1fc2>]
EFLAGS: 00000202 CPU: 1
Dec 15 14:36:41 User-PC kernel: [175576.124181] EIP is at intel_idle+0xc2/0x160
Dec 15 14:36:41 User-PC kernel: [175576.124181] EAX: 00000000 EBX:
00001494 ECX: 00000000 EDX: 00001494
Dec 15 14:36:41 User-PC kernel: [175576.124181] ESI: 00000000 EDI:
00000004 EBP: f60b1f50 ESP: f60b1f28
Dec 15 14:36:41 User-PC kernel: [175576.124181]  DS: 007b ES: 007b FS:
00d8 GS: 00e0 SS: 0068
Dec 15 14:36:41 User-PC kernel: [175576.124181] Process kworker/0:0
(pid: 0, ti=f60b4000 task=f60a8000 task.ti=f60b0000)
Dec 15 14:36:41 User-PC kernel: [175576.124181] Stack:
Dec 15 14:36:41 User-PC kernel: [175576.124181]  0000000b 00000000
77359400 00000001 00000010 00000002 00000001 f6d0a95c
Dec 15 14:36:41 User-PC kernel: [175576.124181]  f6d0aa1c c0817f04
f60b1f60 c04daebb 00000001 00000001 f60b1f84 c0101dea
Dec 15 14:36:41 User-PC kernel: [175576.124181]  c07d0ef4 f60b1f7c
e487e262 f2eb6781 85a608d2 00000000 00000000 f60b1fb0
Dec 15 14:36:41 User-PC kernel: [175576.124181] Call Trace:
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04daebb>] ?
cpuidle_idle_call+0x6b/0x100
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0101dea>] ?
cpu_idle+0x8a/0xf0
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d2702>] ?
start_secondary+0x1e8/0x1ee
Dec 15 14:36:41 User-PC kernel: [175576.124181] Code: f6 89 e0 25 00
e0 ff ff 8b 40 08 a8 08 75 08 b1 01 8b 45 e8 0f 01 c9 e8 cd fc dc ff
29 d8 19 f2 e8 04 d6 da ff 89 c6 89 d3 fb 90 <8d> 74 26 00 85 3d 78 41
7e c0 75 0d 8d 55 f0 b8 05 00 00 00 e8
Dec 15 14:36:41 User-PC kernel: [175576.124181] Call Trace:
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c04daebb>]
cpuidle_idle_call+0x6b/0x100
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c0101dea>] cpu_idle+0x8a/0xf0
Dec 15 14:36:41 User-PC kernel: [175576.124181]  [<c05d2702>]
start_secondary+0x1e8/0x1ee
Dec 15 14:36:41 User-PC kernel: [175576.487562] BUG: scheduling while
atomic: kworker/0:0/0/0x10000100
Dec 15 14:36:41 User-PC kernel: [175576.497058] Modules linked in:
oprofile binfmt_misc bridge stp llc parport_pc ppdev arc4 iwlagn
snd_hda_codec_realtek iwlcore i915 snd_hda_intel mac80211 joydev
snd_hda_codec snd_hwdep snd_pcm snd_seq_midi drm_kms_helper
snd_rawmidi drm snd_seq_midi_event snd_seq snd_timer snd_seq_device
cfg80211 eeepc_wmi usbhid psmouse intel_agp i2c_algo_bit intel_gtt
uvcvideo agpgart videodev sparse_keymap snd shpchp v4l1_compat lp hid
video serio_raw soundcore output snd_page_alloc ahci libahci atl1c
Dec 15 14:36:41 User-PC kernel: [175576.522221] Modules linked in:
oprofile binfmt_misc bridge stp llc parport_pc ppdev arc4 iwlagn
snd_hda_codec_realtek iwlcore i915 snd_hda_intel mac80211 joydev
snd_hda_codec snd_hwdep snd_pcm snd_seq_midi drm_kms_helper
snd_rawmidi drm snd_seq_midi_event snd_seq snd_timer snd_seq_device
cfg80211 eeepc_wmi usbhid psmouse intel_agp i2c_algo_bit intel_gtt
uvcvideo agpgart videodev sparse_keymap snd shpchp v4l1_compat lp hid
video serio_raw soundcore output snd_page_alloc ahci libahci atl1c
Dec 15 14:36:41 User-PC kernel: [175576.550740]
Dec 15 14:36:41 User-PC kernel: [175576.557947] Pid: 0, comm:
kworker/0:0 Tainted: G        W   2.6.37-rc5-wl+ #3 1015PE/1016P
Dec 15 14:36:41 User-PC kernel: [175576.565201] EIP: 0060:[<c03a1fc2>]
EFLAGS: 00000202 CPU: 1
Dec 15 14:36:41 User-PC kernel: [175576.572280] EIP is at intel_idle+0xc2/0x160
Dec 15 14:36:41 User-PC kernel: [175576.579125] EAX: 00000000 EBX:
00001494 ECX: 00000000 EDX: 00001494
Dec 15 14:36:41 User-PC kernel: [175576.585850] ESI: 00000000 EDI:
00000004 EBP: f60b1f50 ESP: f60b1f28
Dec 15 14:36:41 User-PC kernel: [175576.592460]  DS: 007b ES: 007b FS:
00d8 GS: 00e0 SS: 0068
Dec 15 14:36:41 User-PC kernel: [175576.599021] Process kworker/0:0
(pid: 0, ti=f60b4000 task=f60a8000 task.ti=f60b0000)
Dec 15 14:36:41 User-PC kernel: [175576.605632] Stack:
Dec 15 14:36:41 User-PC kernel: [175576.612158]  0000000b 00000000
77359400 00000001 00000010 00000002 00000001 f6d0a95c
Dec 15 14:36:41 User-PC kernel: [175576.618953]  f6d0aa1c c0817f04
f60b1f60 c04daebb 00000001 00000001 f60b1f84 c0101dea
Dec 15 14:36:41 User-PC kernel: [175576.625818]  c07d0ef4 f60b1f7c
e487e262 f2eb6781 85a608d2 00000000 00000000 f60b1fb0
Dec 15 14:36:41 User-PC kernel: [175576.632737] Call Trace:
Dec 15 14:36:41 User-PC kernel: [175576.639461]  [<c04daebb>] ?
cpuidle_idle_call+0x6b/0x100
Dec 15 14:36:41 User-PC kernel: [175576.646168]  [<c0101dea>] ?
cpu_idle+0x8a/0xf0
Dec 15 14:36:41 User-PC kernel: [175576.652826]  [<c05d2702>] ?
start_secondary+0x1e8/0x1ee
Dec 15 14:36:41 User-PC kernel: [175576.659441] Code: f6 89 e0 25 00
e0 ff ff 8b 40 08 a8 08 75 08 b1 01 8b 45 e8 0f 01 c9 e8 cd fc dc ff
29 d8 19 f2 e8 04 d6 da ff 89 c6 89 d3 fb 90 <8d> 74 26 00 85 3d 78 41
7e c0 75 0d 8d 55 f0 b8 05 00 00 00 e8
Dec 15 14:36:41 User-PC kernel: [175576.673805] Call Trace:
Dec 15 14:36:41 User-PC kernel: [175576.680668]  [<c04daebb>]
cpuidle_idle_call+0x6b/0x100
Dec 15 14:36:41 User-PC kernel: [175576.687612]  [<c0101dea>] cpu_idle+0x8a/0xf0
Dec 15 14:36:41 User-PC kernel: [175576.694516]  [<c05d2702>]
start_secondary+0x1e8/0x1ee
Dec 15 14:36:41 User-PC kernel: [175576.711906] BUG: scheduling while
atomic: kworker/0:0/0/0x10000100
Dec 15 14:36:41 User-PC kernel: [175576.716280] Modules linked in:
oprofile binfmt_misc bridge stp llc parport_pc ppdev arc4 iwlagn
snd_hda_codec_realtek iwlcore i915 snd_hda_intel mac80211 joydev
snd_hda_codec snd_hwdep snd_pcm snd_seq_midi drm_kms_helper
snd_rawmidi drm snd_seq_midi_event snd_seq snd_timer snd_seq_device
cfg80211 eeepc_wmi usbhid psmouse intel_agp i2c_algo_bit intel_gtt
uvcvideo agpgart videodev sparse_keymap snd shpchp v4l1_compat lp hid
video serio_raw soundcore output snd_page_alloc ahci libahci atl1c
Dec 15 14:36:41 User-PC kernel: [175576.734197] Modules linked in:
oprofile binfmt_misc bridge stp llc parport_pc ppdev arc4 iwlagn
snd_hda_codec_realtek iwlcore i915 snd_hda_intel mac80211 joydev
snd_hda_codec snd_hwdep snd_pcm snd_seq_midi drm_kms_helper
snd_rawmidi drm snd_seq_midi_event snd_seq snd_timer snd_seq_device
cfg80211 eeepc_wmi usbhid psmouse intel_agp i2c_algo_bit intel_gtt
uvcvideo agpgart videodev sparse_keymap snd shpchp v4l1_compat lp hid
video serio_raw soundcore output snd_page_alloc ahci libahci atl1c
Dec 15 14:36:41 User-PC kernel: [175576.753330]
Dec 15 14:36:41 User-PC kernel: [175576.757845] Pid: 0, comm:
kworker/0:0 Tainted: G        W   2.6.37-rc5-wl+ #3 1015PE/1016P
Dec 15 14:36:41 User-PC kernel: [175576.762389] EIP: 0060:[<c03a1fc2>]
EFLAGS: 00000202 CPU: 1
Dec 15 14:36:41 User-PC kernel: [175576.766809] EIP is at intel_idle+0xc2/0x160
Dec 15 14:36:41 User-PC kernel: [175576.771119] EAX: 00000000 EBX:
00001494 ECX: 00000000 EDX: 00001494
Dec 15 14:36:41 User-PC kernel: [175576.775348] ESI: 00000000 EDI:
00000004 EBP: f60b1f50 ESP: f60b1f28
Dec 15 14:36:41 User-PC kernel: [175576.780037]  DS: 007b ES: 007b FS:
00d8 GS: 00e0 SS: 0068
Dec 15 14:36:41 User-PC kernel: [175576.784159] Process kworker/0:0
(pid: 0, ti=f60b4000 task=f60a8000 task.ti=f60b0000)
Dec 15 14:36:41 User-PC kernel: [175576.788286] Stack:
Dec 15 14:36:41 User-PC kernel: [175576.792375]  0000000b 00000000
77359400 00000001 00000010 00000002 00000001 f6d0a95c
