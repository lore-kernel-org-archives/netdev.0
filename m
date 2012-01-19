From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: inet6_dump_fib  lock held when returning to user space
Date: Thu, 19 Jan 2012 11:48:51 +0100
Message-ID: <201201191148.52121.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:59683 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab2ASKsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 05:48:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello
Have this one been seen before ?
It happens during a container start i.e. in a netns,

[   19.232941] ================================================
[   19.268785] [ BUG: lock held when returning to user space! ]
[   19.270146] 3.2.0+ #14 Tainted: G        W   
[   19.271217] ------------------------------------------------
[   19.272968] nsm/1042 is leaving the kernel with locks still held!
[   19.274603] 1 lock held by nsm/1042:
[   19.275524]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff8136a9b2>] inet6_dump_fib+0xbd/0x34a

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
