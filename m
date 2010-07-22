From: Sven Geggus <sven@gegg.us>
Subject: minstrel_tx_status mac80211 WARNINGs in vanilla 2.6.34.1
Date: Thu, 22 Jul 2010 14:30:01 +0200
Message-ID: <20100722123000.GA16657@geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nerdhammel.gnuher.de ([88.198.0.170]:56130 "EHLO
	nerdhammel.gnuher.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755530Ab0GVMs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 08:48:58 -0400
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by nerdhammel.gnuher.de (envelope-from
	<sven@gegg.us>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	id 1Obuua-0003w6-LA
	for netdev@vger.kernel.org; Thu, 22 Jul 2010 14:30:04 +0200
Received: from sven  by ultimate100.geggus.net (envelope-from
	<sven@gegg.us>)
	with local (Exim 4.69)
	id 1ObuuX-0004NA-5c
	for netdev@vger.kernel.org; Thu, 22 Jul 2010 14:30:01 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

running vanilla 2.6.34.1 I get the following warnings in  kernel log:

WARNING: at net/mac80211/rc80211_minstrel.c:70 minstrel_tx_status+0x67/0xd1 [mac80211]()
Hardware name: SCENIC E300/E600
Modules linked in: i915 drm_kms_helper drm video backlight output lp loop
snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm_oss snd_mixer_oss snd_pcm
snd_seq_dummy zd1211rw snd_seq_oss usbhid mac80211 option cfg80211
snd_seq_midi usbserial snd_rawmidi snd_seq_midi_event snd_seq snd_timer
snd_seq_device snd parport_pc ehci_hcd uhci_hcd soundcore intel_agp parport
usbcore nls_base snd_page_alloc agpgart rng_core floppy sg
Pid: 0, comm: swapper Tainted: G        W  2.6.34.1 #3
Call Trace:
 [<c102af25>] warn_slowpath_common+0x60/0x90
 [<c102af62>] warn_slowpath_null+0xd/0x10
 [<f83cbd48>] minstrel_tx_status+0x67/0xd1 [mac80211]
 [<f83b6eb1>] ieee80211_tx_status+0x1f6/0x5ac [mac80211]
 [<c1261533>] ? skb_dequeue+0x45/0x4c
 [<f83b6896>] ieee80211_tasklet_handler+0x61/0xd6 [mac80211]
 [<c102ed7d>] tasklet_action+0x62/0x9f
 [<c102f331>] __do_softirq+0x77/0xe5
 [<c102f3c5>] do_softirq+0x26/0x2b
 [<c102f52f>] irq_exit+0x29/0x66
 [<c1003e90>] do_IRQ+0x85/0x9b
 [<c1002d29>] common_interrupt+0x29/0x30
 [<c10083ac>] ? default_idle+0x2d/0x42
 [<c1001a9b>] cpu_idle+0x44/0x71
 [<c12e00de>] rest_init+0x96/0x98
 [<c1498862>] start_kernel+0x2a5/0x2aa
 [<c14980b7>] i386_start_kernel+0xb7/0xbf
---[ end trace f22ceacef336878f ]---

Wireless driver is zd1211rw.

Did not test with older kernel because this device has not been in user on
this machine before.

WLAN does however seem to work anyway.

Regards

Sven

-- 
The source code is not comprehensible
                 (found in bug section of man 8 telnetd on Redhat Linux)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
