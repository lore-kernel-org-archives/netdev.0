From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Fri, 14 Jun 2013 07:53:46 +0200
Message-ID: <20130614055346.GB6547@sig21.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
 <20130613222411.GA5396@sig21.net>
 <1371162553.8335.28.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, romieu@fr.zoreil.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:59004 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751320Ab3FNFxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jun 2013 01:53:53 -0400
Content-Disposition: inline
In-Reply-To: <1371162553.8335.28.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 12:29:13AM +0200, Johannes Berg wrote:
> On Fri, 2013-06-14 at 00:24 +0200, Johannes Stezenbach wrote:
> 
> > and after "ifconfig eth0 up":
> > 
> > [  539.482153] alx 0000:03:00.0: irq 45 for MSI/MSI-X
> > [  539.482249] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> > [  539.483169] alx 0000:03:00.0 eth0: NIC Up: 1 Gbps Full
> > [  539.483354] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> > [  544.801438] ------------[ cut here ]------------
> > [  544.801458] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x19b/0x201()
> > [  544.801462] Hardware name: System Product Name
> > [  544.801464] NETDEV WATCHDOG: eth0 (alx): transmit queue 0 timed out
> 
> Hmm, this is odd. I might just be forgetting to set something.
> 
> > 03:00.0 Ethernet controller: Qualcomm Atheros AR8161 Gigabit Ethernet (rev 08)
> 
> OTOH, I have a 8171, so maybe I messed up with my simplifications or it
> simply doesn't work.
> 
> > Any idea what to try?
> 
> Does it still pass traffic after that? Or is it actually dead?

It is dead.  Not interrupts, I tried ping from both ends
of the link (link LED flashes on RX).

Johannes
