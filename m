From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: pktgen crash with 2.6.30
Date: Wed, 22 Jul 2009 10:35:12 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0907221032290.2211@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:35236 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753174AbZGVHfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 03:35:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

using the conf-1-1 script over 2.6.30 I came across this crash in few seconds,
I have found a sign for a similar report in the archives nor any fix in the
2.6..30 stable tree, did other people see this as well?

pktgen v2.70: Packet Generator for packet performance testing.
BUG: spinlock bad magic on CPU#0, kpktgend_0/21800
 lock: ffff880215d27418, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
Pid: 21800, comm: kpktgend_0 Not tainted 2.6.30 #1
Call Trace:
 [<ffffffff8032959f>] ? _raw_spin_lock+0x22/0x122
 [<ffffffffa04a11f6>] ? pktgen_thread_worker+0xf45/0x126e [pktgen]
 [<ffffffffa03ba037>] ? vlan_dev_hwaccel_hard_start_xmit+0x0/0x65 [8021q]
 [<ffffffff8049ee1e>] ? thread_return+0x3e/0x97
 [<ffffffff80246cda>] ? autoremove_wake_function+0x0/0x2e
 [<ffffffffa04a02b1>] ? pktgen_thread_worker+0x0/0x126e [pktgen]
 [<ffffffffa04a02b1>] ? pktgen_thread_worker+0x0/0x126e [pktgen]
 [<ffffffff80246bd0>] ? kthread+0x54/0x84
 [<ffffffff8020bdba>] ? child_rip+0xa/0x20
 [<ffffffff804a065b>] ? _spin_unlock_irq+0xb/0xc
 [<ffffffff80246b7c>] ? kthread+0x0/0x84
 [<ffffffff8020bdb0>] ? child_rip+0x0/0x20


Or.
