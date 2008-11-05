From: Milan Kocian <milon@wq.cz>
Subject: Re: [Bugme-new] [Bug 11955] New: WARNING: at
	net/sched/sch_generic.c:219 dev_watchdog+0x24b/0x25a()
Date: Wed, 5 Nov 2008 11:04:59 +0100
Message-ID: <20081105100458.GC18121@ntm.vs.lam.cz>
References: <bug-11955-10286@http.bugzilla.kernel.org/> <20081105010247.5e7d802c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	ralf.hildebrandt@charite.de, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srw1.wq.cz ([212.71.155.176]:59667 "EHLO srw1.wq.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754420AbYKEKFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 05:05:06 -0500
Content-Disposition: inline
In-Reply-To: <20081105010247.5e7d802c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2008 at 01:02:47AM -0800, Andrew Morton wrote:
 > 
> > [28739.530306] bnx2: eth0 NIC Copper Link is Up, 1000 Mbps full duplex, receive
> > & transmit flow control ON
> > [221569.991014] ------------[ cut here ]------------
> > [221569.991064] WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0x24b/0x25a()
 
Only for your info, it looks like a warning, I posted few days ago. 
But trace path is different. (I use e1000e and have disabled hr-timers). I sent
similar warning with 2.6.26.5 kernel.

-- 
Milan Kocian
