From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: net-next/unix: BUG: using smp_processor_id() in preemptible
Date: Sat, 22 Nov 2008 23:04:53 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811221634370.10534@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41416 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbYKVVE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 16:04:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got plenty of these from sock_prot_inuse_add:

BUG: using smp_processor_id() in preemptible [00000000] code: rcS/1146

caller is sock_prot_inuse_add+0x24/0x42
Pid: 1146, comm: rcS Not tainted 2.6.28-rc6-01121-g89a2f15 #76
Call Trace:
 [<ffffffff80365767>] debug_smp_processor_id+0xd3/0xe8
 [<ffffffff80485a0f>] sock_prot_inuse_add+0x24/0x42
 [<ffffffff80514cdd>] unix_create1+0x161/0x176
 [<ffffffff80514d52>] unix_create+0x60/0x6b
 [<ffffffff80483f66>] __sock_create+0x144/0x1bd
 [<ffffffff80483edb>] ? __sock_create+0xb9/0x1bd
 [<ffffffff8048402d>] sock_create+0x2d/0x2f
 [<ffffffff80484274>] sys_socket+0x29/0x5b
 [<ffffffff8020c10a>] system_call_fastpath+0x16/0x1b


-- 
 i.
