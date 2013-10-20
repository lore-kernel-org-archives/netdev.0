From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 63321] New: tcp_fastretrans_alert
Date: Sun, 20 Oct 2013 13:40:23 -0700
Message-ID: <20131020134023.44054f6d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:58315 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab3JTUk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 16:40:26 -0400
Received: by mail-pd0-f173.google.com with SMTP id r10so4532647pdi.32
        for <netdev@vger.kernel.org>; Sun, 20 Oct 2013 13:40:26 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id sb9sm16365807pbb.0.2013.10.20.13.40.25
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sun, 20 Oct 2013 13:40:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 20 Oct 2013 06:20:25 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 63321] New: tcp_fastretrans_alert


https://bugzilla.kernel.org/show_bug.cgi?id=63321

            Bug ID: 63321
           Summary: tcp_fastretrans_alert
           Product: Networking
           Version: 2.5
    Kernel Version: 3.11.6
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: warrior-elite@yandex.ru
        Regression: No

[  865.064799] ------------[ cut here ]------------
[  865.064813] WARNING: CPU: 0 PID: 0 at
/home/apw/COD/linux/net/ipv4/tcp_input.c:2711
tcp_fastretrans_alert+0x5df/0x620()
[  865.064815] Modules linked in: pci_stub vboxpci(OF) vboxnetadp(OF)
vboxnetflt(OF) joydev hid_generic usbhid hid vboxdrv(OF) binfmt_misc
snd_hda_codec_realtek ppdev uvcvideo videobuf2_vmalloc videobuf2_memops
videobuf2_core videodev snd_usb_audio snd_usbmidi_lib nvidia(POF) snd_hda_intel
snd_hda_codec snd_hwdep snd_pcm kvm_amd kvm snd_page_alloc snd_seq_midi
snd_seq_midi_event snd_rawmidi snd_seq microcode snd_seq_device snd_timer snd
serio_raw soundcore edac_core k10temp edac_mce_amd drm sp5100_tco ohci_pci
i2c_piix4 wmi mac_hid parport_pc lp parport pata_acpi ahci r8169 pata_atiixp
libahci mii
[  865.064843] CPU: 0 PID: 0 Comm: swapper/0 Tainted: PF          O
3.11.6-031106-generic #201310181453
[  865.064845] Hardware name: Gigabyte Technology Co., Ltd.
GA-MA770-UD3/GA-MA770-UD3, BIOS FKb 07/08/2010
[  865.064846]  0000000000000a97 ffff88012fc039a0 ffffffff81714a56
000000000000259d
[  865.064849]  0000000000000000 ffff88012fc039e0 ffffffff8106539c
ffff88012fc03a00
[  865.064851]  ffff880114f45400 000000000000000c 0000000000004120
0000000000000001
[  865.064853] Call Trace:
[  865.064855]  <IRQ>  [<ffffffff81714a56>] dump_stack+0x46/0x58
[  865.064861]  [<ffffffff8106539c>] warn_slowpath_common+0x8c/0xc0
[  865.064863]  [<ffffffff810653ea>] warn_slowpath_null+0x1a/0x20
[  865.064865]  [<ffffffff8165f9df>] tcp_fastretrans_alert+0x5df/0x620
[  865.064867]  [<ffffffff816608c8>] tcp_ack+0x498/0x630
[  865.064868]  [<ffffffff8166109a>] tcp_rcv_established+0x31a/0x780
[  865.064871]  [<ffffffff8166b3b5>] tcp_v4_do_rcv+0x155/0x240
[  865.064873]  [<ffffffff8166d230>] tcp_v4_rcv+0x5f0/0x770
[  865.064875]  [<ffffffff81099f42>] ? try_to_wake_up+0x192/0x210
[  865.064878]  [<ffffffff81647a6e>] ip_local_deliver_finish+0xce/0x250
[  865.064880]  [<ffffffff81647d7b>] ip_local_deliver+0x4b/0x90
[  865.064881]  [<ffffffff81647761>] ip_rcv_finish+0x121/0x360
[  865.064883]  [<ffffffff81647ff6>] ip_rcv+0x236/0x350
[  865.064886]  [<ffffffff81611a2a>] __netif_receive_skb_core+0x5ca/0x720
[  865.064888]  [<ffffffff81611ba1>] __netif_receive_skb+0x21/0x70
[  865.064890]  [<ffffffff81611c13>] netif_receive_skb+0x23/0x90
[  865.064891]  [<ffffffff81612330>] napi_gro_receive+0xb0/0x130
[  865.064898]  [<ffffffffa00217f2>] rtl_rx+0xe2/0x320 [r8169]
[  865.064903]  [<ffffffffa00254c5>] rtl8169_poll+0x105/0x120 [r8169]
[  865.064905]  [<ffffffff8108d00e>] ? hrtimer_get_next_event+0xce/0xd0
[  865.064907]  [<ffffffff81612ca4>] net_rx_action+0x134/0x260
[  865.064910]  [<ffffffff814734c1>] ? add_interrupt_randomness+0x41/0x190
[  865.064913]  [<ffffffff8106a510>] __do_softirq+0xe0/0x280
[  865.064915]  [<ffffffff8172005e>] ? _raw_spin_lock+0xe/0x20
[  865.064918]  [<ffffffff8172ae9c>] call_softirq+0x1c/0x30
[  865.064921]  [<ffffffff81015e35>] do_softirq+0x65/0xa0
[  865.064923]  [<ffffffff8106a82e>] irq_exit+0x9e/0xc0
[  865.064924]  [<ffffffff8172b7a3>] do_IRQ+0x63/0xe0
[  865.064926]  [<ffffffff8172066d>] common_interrupt+0x6d/0x6d
[  865.064927]  <EOI>  [<ffffffff810504f6>] ? native_safe_halt+0x6/0x10
[  865.064932]  [<ffffffff8101c803>] default_idle+0x23/0xe0
[  865.064934]  [<ffffffff8101c93a>] amd_e400_idle+0x7a/0x100
[  865.064936]  [<ffffffff8101d096>] arch_cpu_idle+0x26/0x30
[  865.064938]  [<ffffffff810ba77e>] cpu_idle_loop+0x7e/0x250
[  865.064940]  [<ffffffff810ba9bb>] cpu_startup_entry+0x6b/0x70
[  865.064943]  [<ffffffff816fcbd7>] rest_init+0x77/0x80
[  865.064946]  [<ffffffff81d24f23>] start_kernel+0x407/0x414
[  865.064948]  [<ffffffff81d249ae>] ? do_early_param+0x87/0x87
[  865.064950]  [<ffffffff81d24120>] ? early_idt_handlers+0x120/0x120
[  865.064952]  [<ffffffff81d245e8>] x86_64_start_reservations+0x2a/0x2c
[  865.064954]  [<ffffffff81d246f2>] x86_64_start_kernel+0x108/0x117
[  865.064955] ---[ end trace 7fed0fa1e4d5f06f ]---

-- 
You are receiving this mail because:
You are the assignee for the bug.
