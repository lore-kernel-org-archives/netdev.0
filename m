From: Milan Kocian <milon@wq.cz>
Subject: WARNING: at net/sched/sch_generic.c:219
Date: Mon, 3 Nov 2008 10:26:10 +0100
Message-ID: <20081103092609.GA8659@ntm.vs.lam.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([212.71.155.176]:52459 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754772AbYKCJ0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 04:26:15 -0500
Received: from [172.24.19.5] (helo=ntm.vs.lam.cz)
	by srw1.wq.cz with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <milon@wq.cz>)
	id 1KwvgE-0001t3-Ue
	for netdev@vger.kernel.org; Mon, 03 Nov 2008 10:25:05 +0100
Received: from milon by ntm.vs.lam.cz with local (Exim 4.69)
	(envelope-from <milon@wq.cz>)
	id 1KwvhK-0002GF-7h
	for netdev@vger.kernel.org; Mon, 03 Nov 2008 10:26:10 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello,

for your info I have here one warning. Kernel 2.6.27.4.
Machine have minimal load and traffic (I can say, it does nothing :-).
Probably its related to link up/down. (kvm module is only loaded, not 
used)


Nov  1 19:46:40 srw1 kernel: 0000:0d:00.0: eth0: Detected Tx Unit Hang:
Nov  1 19:46:40 srw1 kernel: TDH                  <bf>
Nov  1 19:46:40 srw1 kernel: TDT                  <cd>
Nov  1 19:46:40 srw1 kernel: next_to_use          <cd>
Nov  1 19:46:40 srw1 kernel: next_to_clean        <bf>
Nov  1 19:46:40 srw1 kernel: buffer_info[next_to_clean]:
Nov  1 19:46:40 srw1 kernel: time_stamp           <1020c297e>
Nov  1 19:46:40 srw1 kernel: next_to_watch        <bf>
Nov  1 19:46:40 srw1 kernel: jiffies              <1020c3cb4>
Nov  1 19:46:40 srw1 kernel: next_to_watch.status <0>
Nov  1 19:46:42 srw1 kernel: 0000:0d:00.0: eth0: Detected Tx Unit Hang:
Nov  1 19:46:42 srw1 kernel: TDH                  <bf>
Nov  1 19:46:42 srw1 kernel: TDT                  <cd>
Nov  1 19:46:42 srw1 kernel: next_to_use          <cd>
Nov  1 19:46:42 srw1 kernel: next_to_clean        <bf>
Nov  1 19:46:42 srw1 kernel: buffer_info[next_to_clean]:
Nov  1 19:46:42 srw1 kernel: time_stamp           <1020c297e>
Nov  1 19:46:42 srw1 kernel: next_to_watch        <bf>
Nov  1 19:46:42 srw1 kernel: jiffies              <1020c3f0c>
Nov  1 19:46:42 srw1 kernel: next_to_watch.status <0>
Nov  1 19:46:43 srw1 kernel: ------------[ cut here ]------------
Nov  1 19:46:43 srw1 kernel: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0x22e/0x240()
Nov  1 19:46:43 srw1 kernel: NETDEV WATCHDOG: eth0 (e1000e): transmit timed out
Nov  1 19:46:43 srw1 kernel: Modules linked in: kvm_intel kvm ipv6 loop e1000e
Nov  1 19:46:43 srw1 kernel: Pid: 0, comm: swapper Not tainted 2.6.27.4 #2
Nov  1 19:46:43 srw1 kernel: 
Nov  1 19:46:43 srw1 kernel: Call Trace:
Nov  1 19:46:43 srw1 kernel: <IRQ>  [<ffffffff8023449d>] warn_slowpath+0xcd/0x120
Nov  1 19:46:43 srw1 kernel: [<ffffffff8023521d>] vprintk+0x16d/0x3c0
Nov  1 19:46:43 srw1 kernel: [<ffffffff8038b829>] __next_cpu+0x19/0x30
Nov  1 19:46:43 srw1 kernel: [<ffffffff8022bcec>] find_busiest_group+0x1dc/0x950
Nov  1 19:46:43 srw1 kernel: [<ffffffff803914d1>] strlcpy+0x41/0x50
Nov  1 19:46:43 srw1 kernel: [<ffffffff8042e49e>] dev_watchdog+0x22e/0x240
Nov  1 19:46:43 srw1 kernel: [<ffffffff80424c56>] neigh_periodic_timer+0x146/0x1c0
Nov  1 19:46:43 srw1 kernel: [<ffffffff8024f178>] getnstimeofday+0x48/0xc0
Nov  1 19:46:43 srw1 kernel: [<ffffffff8042e270>] dev_watchdog+0x0/0x240
Nov  1 19:46:43 srw1 kernel: [<ffffffff8023e6be>] run_timer_softirq+0x12e/0x200
Nov  1 19:46:43 srw1 kernel: [<ffffffff80239e43>] __do_softirq+0x73/0xf0
Nov  1 19:46:43 srw1 kernel: [<ffffffff8020cb8c>] call_softirq+0x1c/0x30
Nov  1 19:46:43 srw1 kernel: [<ffffffff8020eb75>] do_softirq+0x35/0x70
Nov  1 19:46:43 srw1 kernel: [<ffffffff8021c13e>] smp_apic_timer_interrupt+0x7e/0xc0
Nov  1 19:46:43 srw1 kernel: [<ffffffff8020c5d6>] apic_timer_interrupt+0x66/0x70
Nov  1 19:46:43 srw1 kernel: <EOI>  [<ffffffff8021329c>] mwait_idle+0x3c/0x50
Nov  1 19:46:43 srw1 kernel: [<ffffffff8020a86c>] cpu_idle+0x5c/0x90
Nov  1 19:46:43 srw1 kernel: 
Nov  1 19:46:43 srw1 kernel: ---[ end trace c45f300d9ee4877c ]---
Nov  1 19:46:45 srw1 kernel: 0000:0d:00.0: eth0: Link is Up 10 Mbps Full Duplex, Flow Control: None
Nov  1 19:46:45 srw1 kernel: 0000:0d:00.0: eth0: 10/100 speed: disabling TSO
Nov  1 19:48:40 srw1 kernel: 0000:0d:00.0: eth0: Detected Tx Unit Hang:
Nov  1 19:48:40 srw1 kernel: TDH                  <cc>
Nov  1 19:48:40 srw1 kernel: TDT                  <d7>
Nov  1 19:48:40 srw1 kernel: next_to_use          <d7>
Nov  1 19:48:40 srw1 kernel: next_to_clean        <ca>
Nov  1 19:48:40 srw1 kernel: buffer_info[next_to_clean]:
Nov  1 19:48:40 srw1 kernel: time_stamp           <1020cb4e0>
Nov  1 19:48:40 srw1 kernel: next_to_watch        <cc>
Nov  1 19:48:40 srw1 kernel: jiffies              <1020cc828>
Nov  1 19:48:40 srw1 kernel: next_to_watch.status <0>
Nov  1 19:48:43 srw1 kernel: 0000:0d:00.0: eth0: Link is Up 10 Mbps Full Duplex, Flow Control: None
Nov  1 19:48:43 srw1 kernel: 0000:0d:00.0: eth0: 10/100 speed: disabling TSO


Regards,

-- 
Milan Kocian
