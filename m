From: Bongani Hlope <bonganilinux@mweb.co.za>
Subject: [OOPS] 2.6.23-rc1 Seems to be network related
Date: Wed, 1 Aug 2007 02:57:48 +0200
Message-ID: <200708010257.48417.bonganilinux@mweb.co.za>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-04.jhb.wbs.co.za ([196.2.97.3]:10988 "EHLO
	mail-04.jhb.wbs.co.za" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbXHAA6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 20:58:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I'm not sure if the first email went through, resending without .config 
attachment.

I got this partial Oops on my work laptop (DELL D800), while using the linux 
2.6.23-rc1 kernel. I've been using this kernel ever since it was released and 
this is the first and only time it did not boot. It was around the time it 
should have been trying to connect to my linksys wireless router (which has 
been working fine everyday since the 2.6.23-rc1 kernel was released).

I copied what was on screen by hand, so some info is missing. I don't know how 
to reproduce it.

Call Trace:
[<c0104cbc>] show_trace_log_lvl+0x1a/0x2f
[<c0104d6c>] show_stack_log_lvl+0x9b/0xa3
[<c0104f36>] show_registers+0x1c2/0x2db
[<c0105151>] die+0x02/0x1de
[<c01052b6>] do_trap+0x89/0xa2
[<c010558e>] do_invalid_op+0x88/0x92
[<c035a162>] error_code+0x6a/0x70
[<c0114efa>] kmap_atomic+0xe/0x10
[<c014a29c>] get_page_from_freelist+0x24c/0x3...
[<c015dd06>] __alloc_pages+0x53/0x27d
[<c015da60>] kmem_cache_alloc+0x32/0x68
[<c02e5065>] dst_alloc+0x28/0x60
[<c02f45fe>] ip_route_input+0x9b9/0xbba
[<c0314835>] arp_process+0x155/0x4e1
[<c0314caa>] arp_rcv+0xe9/0xfd
[<c02e1660>] netif_receive_skb+0x16e/0x1eb
[<c02e2efa>] process_backlog+0x71/0xda
[<c02e2fb9>] net_rx_action+0x56/0xee
[<c011f437>] __do_softirq+0x38/0x7a
[<c0106145>] do_soft_irq+0x41/0x91
[<c011f3c5>] irq_exit+0x2c/0x66
[<c010644a>] do_IRQ+0xb7/0xcd
[<c01047eb>] common_interrupt+0x23/0x28
[<c0151f87>] handle_mm_fault+0x1fe/0x57e
[<c035a162>] error_code+0x6a/0x70
=======================
EIP: [<c0114e87>] kmap_atomic_prot+0x27/0x8..


Linux bongani_nb 2.6.23-rc1 #4 PREEMPT Mon Jul 23 12:11:40 SAST 2007 i686 
Intel(R) Pentium(R) M processor 1600MHz GNU/Linux

Gnu C                  4.1.2
Gnu make               3.81
binutils               2.17.50.0.9
util-linux             2.12r
mount                  2.12r
module-init-tools      3.3-pre2
e2fsprogs              1.39
pcmciautils            014
PPP                    2.4.4
Linux C Library        > libc.2.4
Dynamic linker (ldd)   2.4
Procps                 3.2.7
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.97
udev                   106
wireless-tools         28
Modules Loaded         tg3 snd_seq_dummy snd_seq_oss snd_seq_midi_event 
snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_intel8x0 snd_ac97_codec 
ac97_bus snd_pcm snd_timer snd_page_alloc snd soundcore video output thermal 
sbs processor fan container button battery ac pcmcia yenta_socket 
rsrc_nonstatic pcmcia_core intel_agp hidp nvram rfcomm l2cap ipw2100 
ieee80211 ieee80211_crypt usbhid hci_usb bluetooth ohci1394 ieee1394 ehci_hcd 
uhci_hcd joydev evdev

I'm sorry I can't provide more info, this is completely random and it's the 
first time it ever happened.
