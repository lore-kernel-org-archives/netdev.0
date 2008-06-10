From: "Igor Podlesny" <for.poige+linux@gmail.com>
Subject: Hi!Couldn't you take a look at kernel stack's trace? (ip_route_input+0x91a/0xcc9)
Date: Tue, 10 Jun 2008 21:31:21 +0800
Message-ID: <43d009740806100631m17257a2ud430553db52c960@mail.gmail.com>
Reply-To: for.poige+linux@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:36550 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbYFJNbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 09:31:23 -0400
Received: by wx-out-0506.google.com with SMTP id h29so1209624wxd.4
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2008 06:31:22 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	(2.6.24.7-rt13 works fine)

Jun 10 18:49:01 arch [   56.072421] BUG: unable to handle kernel NULL
pointer dereference at 00000019
Jun 10 18:49:01 arch [   56.072421] IP: [<c0313d75>] ip_route_input+0x91a/0xcc9
Jun 10 18:49:01 arch [   56.072421] *pde = 00000000
Jun 10 18:49:01 arch [   56.072421] Oops: 0002 [#1] PREEMPT SMP
Jun 10 18:49:01 arch [   56.072421] Modules linked in: snd_rtctimer
rtc ip_queue xt_owner ipt_recent ipt_ttl ipt_addrtype ipt_REJECT
iptable_filter ipt_LOG xt_limit xt_DSCP xt_TCPMSS iptable_mangle it87
hwmon_vid hwmon snd_usb_audio snd_usb_lib usbhid hid parport_pc
8250_pnp 8250 serial_core lp ppp_generic parport slhc forcedeth
ohci_hcd ehci_hcd i2c_nforce2 fan button fuse via_rhine 3c59x mii tun
powernow_k8 thermal processor 8021q tuner tea5767 tda8290 tuner_xc2028
tda9887 tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat
compat_ioctl32 v4l2_common videobuf_dma_sg videobuf_core ir_kbd_i2c
ir_common tveeprom i2c_core snd_seq_oss snd_seq_midi_event snd_seq
snd_emu10k1 firmware_class snd_util_mem snd_hwdep snd_pcm_oss
snd_mixer_oss snd_via82xx snd_ac97_codec ac97_bus snd_pcm snd_timer
snd_page_alloc snd_mpu401_uart snd_rawmidi snd_seq_device snd
soundcore loop pcspkr evdev usbcore
Jun 10 18:49:01 arch [   56.072421]
Jun 10 18:49:01 arch [   56.072421] Pid: 8, comm: sirq-net-rx/0 Not
tainted (2.6.25.4-rt4aa-gcc43 #1)
Jun 10 18:49:01 arch [   56.072421] EIP: 0060:[<c0313d75>] EFLAGS:
00010202 CPU: 0
Jun 10 18:49:01 arch [   56.072421] EIP is at ip_route_input+0x91a/0xcc9
Jun 10 18:49:01 arch [   56.072421] EAX: 00000000 EBX: f5a69e00 ECX:
f7477e14 EDX: 00000001
Jun 10 18:49:01 arch [   56.072421] ESI: 0f6ea8c0 EDI: f7477ea4 EBP:
ffffff8f ESP: f7477e38
Jun 10 18:49:01 arch [   56.072421]  DS: 007b ES: 007b FS: 00d8 GS:
0000 SS: 0068 preempt:00000001
Jun 10 18:49:01 arch [   56.072421] Process sirq-net-rx/0 (pid: 8,
ti=f7476000 task=f746c690 task.ti=f7476000)
Jun 10 18:49:01 arch [   56.072421] Stack: 00000000 016ea8c0 f6e2f180
00000001 c04f1964 00000001 f5a69e00 016ea8c0
Jun 10 18:49:01 arch [   56.072421]        00000000 00000000 c04851cc
f786d640 00000000 00000006 00000000 016ea8c0
Jun 10 18:49:01 arch [   56.072421]        0f6ea8c0 00000000 00000000
00000000 00000000 00000000 00000000 00000000
Jun 10 18:49:01 arch [   56.072421] Call Trace:
Jun 10 18:49:01 arch [   56.072421]  [<c024d578>] __next_cpu+0x12/0x21
Jun 10 18:49:01 arch [   56.072421]  [<c0333ee8>] arp_process+0x1fe/0x5fe
Jun 10 18:49:01 arch [   56.072421]  [<c01277f5>] wake_up_process+0xe/0x10
Jun 10 18:49:01 arch [   56.072421]  [<c0172e80>] __kmalloc+0x97/0xcb
Jun 10 18:49:01 arch [   56.072421]  [<c02f16be>] __alloc_skb+0x45/0xf2
Jun 10 18:49:01 arch [   56.072421]  [<c02f58da>] netif_receive_skb+0x2dd/0x30b
Jun 10 18:49:01 arch [   56.072421]  [<c02f5975>] process_backlog+0x6d/0xc1
Jun 10 18:49:01 arch [   56.072421]  [<c02f46a3>] net_rx_action+0x65/0x14c
Jun 10 18:49:01 arch [   56.072421]  [<c01304dd>] ksoftirqd+0x138/0x214
Jun 10 18:49:01 arch [   56.072421]  [<c01303a5>] ksoftirqd+0x0/0x214
Jun 10 18:49:01 arch [   56.072421]  [<c013c30e>] kthread+0x38/0x5d
Jun 10 18:49:01 arch [   56.072421]  [<c013c2d6>] kthread+0x0/0x5d
Jun 10 18:49:01 arch [   56.072421]  [<c0113f3f>] kernel_thread_helper+0x7/0x10
Jun 10 18:49:01 arch [   56.072421]  =======================
Jun 10 18:49:01 arch [   56.072421] Code: ff ff 8b 5c 24 18 f0 ff 4b
04 0f 94 c0 84 c0 74 07 89 d8 e8 32 1b 02 00 83 7c 24 14 00 0f 84 98
03 00 00 8b 54 24 70 85 d2 74 12 <f0> ff 4a 18 0f 94 c0 84 c0 74 07 89
d0 e8 e7 92 02 00 8b 54 24
Jun 10 18:49:01 arch [   56.072421] EIP: [<c0313d75>]
ip_route_input+0x91a/0xcc9 SS:ESP 0068:f7477e38
Jun 10 18:49:01 arch [   56.072421] ---[ end trace 0f990b633467f554 ]---

-- 
End of message. Next message?
