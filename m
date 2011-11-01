From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: pppol2tp over pppoe NULL pointer dereference
Date: Tue, 01 Nov 2011 23:35:16 +0100
Message-ID: <1320186916.4728.1.camel@edumazet-laptop>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Misha Labjuk <spiked.yar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56297 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250Ab1KAWfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 18:35:23 -0400
Received: by wyh15 with SMTP id 15so901182wyh.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 15:35:21 -0700 (PDT)
In-Reply-To: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 novembre 2011 =C3=A0 01:00 +0300, Misha Labjuk a =C3=A9c=
rit :
> pppol2tp over pppoe NULL pointer dereference
>=20
> Kernel panic after establishing pppol2tp tunnel over pppoe connection=
=2E
> Get panic in 5-15 min with 10 mbit/s data transfer speed.
> pppoe and pppol2tp connections stable separately.
>=20
> Linux version 3.1.0 (user@host) (gcc version 4.6.1 (Gentoo 4.6.1-r1
> p1.0, pie-0.4.5) ) #1 SMP Mon Oct 31 18:48:18 MSK 2011
>=20
> [  151.913193] L2TP core driver, V2.0
> [  151.974584] L2TP netlink interface
> [  151.993803] PPPoL2TP kernel driver, V2.0
> [  437.496670] BUG: unable to handle kernel NULL pointer dereference
> at 0000000000000008
> [  437.496683] IP: [<ffffffffa03679dc>] l2tp_recv_common+0x4d3/0x621 =
[l2tp_core]
> [  437.496691] PGD d7840067 PUD cd4e7067 PMD 0
> [  437.496697] Oops: 0002 [#1] SMP
> [  437.496702] CPU 0
> [  437.496704] Modules linked in: l2tp_ppp l2tp_netlink l2tp_core
> firewire_sbp2 sit tunnel4 netconsole it87 hwmon_vid coretemp pppoe
> pppox ppp_generic slhc ipt_MASQUERADE iptable_nat nf_nat
> nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 xt_TCPMSS iptable_mangl=
e
> ip_tables snd_seq_midi snd_emu10k1_synth snd_emux_synth
> snd_seq_virmidi snd_seq_midi_emul snd_seq_dummy snd_seq_oss
> snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss nfsd lockd
> nfs_acl auth_rpcgss sunrpc usb_storage usb_libusual uas usbhid ipv6
> snd_emu10k1 8250_pnp snd_rawmidi snd_hda_codec_realtek snd_ac97_codec
> snd_hda_intel snd_hda_codec uhci_hcd ac97_bus snd_pcm ehci_hcd usbcor=
e
> snd_seq_device snd_timer 8250 snd_util_mem snd_hwdep psmouse snd
> firewire_ohci firewire_core serial_core intel_agp intel_gtt pcspkr
> soundcore r8169 crc_itu_t mii snd_page_alloc processor button
> [  437.497005]
> [  437.497005] Pid: 3274, comm: qbittorrent Not tainted 3.1.0 #1
> Gigabyte Technology Co., Ltd. EP45-EXTREME/EP45-EXTREME
> [  437.497005] RIP: 0010:[<ffffffffa03679dc>]  [<ffffffffa03679dc>]
> l2tp_recv_common+0x4d3/0x621 [l2tp_core]
> [  437.497005] RSP: 0000:ffff88011fc03b90  EFLAGS: 00010296
> [  437.497005] RAX: 0000000000000000 RBX: ffff8800d79e8200 RCX: ffff8=
8011fc10bd0
> [  437.497005] RDX: 0000000000000000 RSI: 0000000000004002 RDI: ffff8=
800d79e8254
> [  437.497005] RBP: ffff88011fc03be0 R08: 0000000000004002 R09: 00000=
00000004002
> [  437.497005] R10: ffff8801091ec87a R11: ffff88011b300000 R12: ffff8=
80118922300
> [  437.497005] R13: 0000000000000000 R14: ffff8800d79e8254 R15: ffff8=
800d79e826c
> [  437.497005] FS:  00007f0ced3e8700(0000) GS:ffff88011fc00000(0000)
> knlGS:0000000000000000
> [  437.497005] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  437.497005] CR2: 0000000000000008 CR3: 00000000c8811000 CR4: 00000=
000000406f0
> [  437.497005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000=
00000000000
> [  437.497005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000=
00000000400
> [  437.497005] Process qbittorrent (pid: 3274, threadinfo
> ffff8800c9906000, task ffff8800db999200)
> [  437.497005] Stack:
> [  437.497005]  ffff88011fc03bb0 ffff8801091ec872 ffff8800d79e8240
> 0000052000000520
> [  437.497005]  ffff88011fc03be0 ffff8800d7844e00 ffff880119099200
> ffff8801091ec872
> [  437.497005]  ffff8800db8b6400 00000000000050cd ffff88011fc03c60
> ffffffffa0367e65
> [  437.497005] Call Trace:
> [  437.497005]  <IRQ>
> [  437.497005]  [<ffffffffa0367e65>] l2tp_udp_encap_recv+0x33b/0x3e6 =
[l2tp_core]
> [  437.497005]  [<ffffffffa0377d96>] ? pppol2tp_setsockopt+0x2e0/0x2e=
0
> [l2tp_ppp]
> [  437.497005]  [<ffffffffa030640c>] ? ipv4_confirm+0x17e/0x198
> [nf_conntrack_ipv4]
> [  437.497005]  [<ffffffffa0377d96>] ? pppol2tp_setsockopt+0x2e0/0x2e=
0
> [l2tp_ppp]
> [  437.497005]  [<ffffffff812eb32b>] udp_queue_rcv_skb+0xee/0x2ce
> [  437.497005]  [<ffffffff812ebba3>] __udp4_lib_rcv+0x2d2/0x536
> [  437.497005]  [<ffffffff812cb046>] ? ip_rcv_finish+0x29a/0x29a
> [  437.497005]  [<ffffffff812ebe1c>] udp_rcv+0x15/0x17
> [  437.497005]  [<ffffffff812cb165>] ip_local_deliver_finish+0x11f/0x=
1c7
> [  437.497005]  [<ffffffff812cb361>] ip_local_deliver+0x75/0x7c
> [  437.497005]  [<ffffffff812cb023>] ip_rcv_finish+0x277/0x29a
> [  437.497005]  [<ffffffff812cb5a1>] ip_rcv+0x239/0x260
> [  437.497005]  [<ffffffff812a46cd>] ? napi_skb_finish+0x21/0x38
> [  437.497005]  [<ffffffff812a3adb>] __netif_receive_skb+0x430/0x462
> [  437.497005]  [<ffffffff8102342f>] ? update_curr+0x53/0x89
> [  437.497005]  [<ffffffff812a3b9d>] process_backlog+0x90/0x151
> [  437.497005]  [<ffffffff812a3e6a>] net_rx_action+0x9e/0x171
> [  437.497005]  [<ffffffff810344b0>] __do_softirq+0x93/0x129
> [  437.497005]  [<ffffffff8133034c>] call_softirq+0x1c/0x30
> [  437.497005]  [<ffffffff8100351c>] do_softirq+0x33/0x6b
> [  437.497005]  [<ffffffff8103470b>] irq_exit+0x52/0xac
> [  437.497005]  [<ffffffff81003251>] do_IRQ+0x98/0xaf
> [  437.497005]  [<ffffffff8132eb6b>] common_interrupt+0x6b/0x6b
> [  437.497005]  <EOI>
> [  437.497005]  [<ffffffff8132f17b>] ? system_call_fastpath+0x16/0x1b
> [  437.497005] Code: 6c e8 57 03 fc e0 e9 22 01 00 00 ff 4b 50 4c 89
> f7 49 8b 14 24 49 c7 04 24 00 00 00 00 49 8b 44 24 08 49 c7 44 24 08
> 00 00 00 00
> [  437.497005]  89 42 08 48 89 10 e8 1d 6f fc e0 41 0f b7 54 24 3e 48=
 8b 43
> [  437.497005] RIP  [<ffffffffa03679dc>] l2tp_recv_common+0x4d3/0x621
> [l2tp_core]
> [  437.497005]  RSP <ffff88011fc03b90>
> [  437.497005] CR2: 0000000000000008
> [  437.498126] ---[ end trace 053df4c7c6743d26 ]---
> [  437.498184] Kernel panic - not syncing: Fatal exception in interru=
pt
> [  437.498187] Pid: 3274, comm: qbittorrent Tainted: G      D     3.1=
=2E0 #1
> [  437.498189] Call Trace:
> [  437.498190]  <IRQ>  [<ffffffff81327c11>] panic+0x8c/0x189
> [  437.498197]  [<ffffffff8100471d>] oops_end+0x81/0x8e
> [  437.498200]  [<ffffffff8132765b>] no_context+0x1fe/0x20d
> [  437.498203]  [<ffffffff81327829>] __bad_area_nosemaphore+0x1bf/0x1=
e0
> [  437.498206]  [<ffffffff812a5308>] ? dev_hard_start_xmit+0x412/0x51=
b
> [  437.498210]  [<ffffffff81327858>] bad_area_nosemaphore+0xe/0x10
> [  437.498213]  [<ffffffff8101c858>] do_page_fault+0x175/0x371
> [  437.498217]  [<ffffffff812a1eba>] ? netif_rx+0xc5/0xd0
> [  437.498281]  [<ffffffffa031ee7d>] ?
> ppp_receive_nonmp_frame+0x58f/0x5cf [ppp_generic]
> [  437.498286]  [<ffffffffa0320625>] ? ppp_receive_frame+0x5c1/0x5e2
> [ppp_generic]
> [  437.498290]  [<ffffffff8132ed6f>] page_fault+0x1f/0x30
> [  437.498293]  [<ffffffffa03679dc>] ? l2tp_recv_common+0x4d3/0x621 [=
l2tp_core]
> [  437.498298]  [<ffffffffa0367e65>] l2tp_udp_encap_recv+0x33b/0x3e6 =
[l2tp_core]
> [  437.498302]  [<ffffffffa0377d96>] ? pppol2tp_setsockopt+0x2e0/0x2e=
0
> [l2tp_ppp]
> [  437.498306]  [<ffffffffa030640c>] ? ipv4_confirm+0x17e/0x198
> [nf_conntrack_ipv4]
> [  437.498310]  [<ffffffffa0377d96>] ? pppol2tp_setsockopt+0x2e0/0x2e=
0
> [l2tp_ppp]
> [  437.498314]  [<ffffffff812eb32b>] udp_queue_rcv_skb+0xee/0x2ce
> [  437.498317]  [<ffffffff812ebba3>] __udp4_lib_rcv+0x2d2/0x536
> [  437.498321]  [<ffffffff812cb046>] ? ip_rcv_finish+0x29a/0x29a
> [  437.498324]  [<ffffffff812ebe1c>] udp_rcv+0x15/0x17
> [  437.498328]  [<ffffffff812cb165>] ip_local_deliver_finish+0x11f/0x=
1c7
> [  437.498332]  [<ffffffff812cb361>] ip_local_deliver+0x75/0x7c
> [  437.498391]  [<ffffffff812cb023>] ip_rcv_finish+0x277/0x29a
> [  437.498394]  [<ffffffff812cb5a1>] ip_rcv+0x239/0x260
> [  437.498398]  [<ffffffff812a46cd>] ? napi_skb_finish+0x21/0x38
> [  437.498401]  [<ffffffff812a3adb>] __netif_receive_skb+0x430/0x462
> [  437.498404]  [<ffffffff8102342f>] ? update_curr+0x53/0x89
> [  437.498408]  [<ffffffff812a3b9d>] process_backlog+0x90/0x151
>=20
>=20
> Software:
> Gnu C                  4.6.1
> Gnu make            3.82
> binutils                 2.21.1
> openl2tp               1.8-r3
>=20
> l2tp_recv_common+0x4d3/0x621 is match to
> net/l2tp/l2tp_core.c:429:__skb_unlink(skb, &session->reorder_q);
> skb->next is NULL.

Hi Misha

On what kind of NIC this is happening ?
