From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed
 out
Date: Sat, 2 Jun 2012 11:13:35 +0200
Message-ID: <20120602111335.0b94fb59@stein>
References: <20120501182405.3dda59b9@stein>
	<20120501172748.GA17117@electric-eye.fr.zoreil.com>
	<20120501200423.6804dcf0@stein>
	<20120501200403.GA20763@electric-eye.fr.zoreil.com>
	<20120503204813.65468df7@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:51777 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759150Ab2FBJNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 05:13:40 -0400
In-Reply-To: <20120503204813.65468df7@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 03 Stefan Richter wrote:
> On May 01 Francois Romieu wrote:
> [...]
> > Can you apply the patch below on top of current ethtool
> > (git://git.kernel.org/pub/scm/network/ethtool/ethtool.git) and see
> > if it is enough to compare the register dumps (ethtool -d eth0).
> [...]
> > This is a firmware free chipset anyway. Nothing strange in the interface
> > stats (ethtool -S eth0) ?
> > 
> > You may have to narrow things. Can you check if the r8169.c at
> > 036dafa28da1e2565a8529de2ae663c37b7a0060 behaves the same ?
> 
> I will follow up on this eventually, but it may take quite some time due
> to interfering work.
> 
> Thank you for looking into it and giving directions,

I haven't had time to look further into it yet.  Just two minor findings:

(a) After update from 3.4-rc5 to 3.4, the problem persisted.

(b) Later I noticed that silent file corruptions on FireWire disks happened
and happen under 3.4-rc5 and 3.4, so I reverted into 3.3.1 which fixed
that issue.  Furthermore, since 6 days uptime of 3.3.1, the eth0 (r8169)
transmit queue time-out did never occur.

I have no idea whether the FireWire and networking issues might be somehow
connected, and I still lack time to investigate these issues (using Linux
only at home, not at work), but I will eventually get back to it.
-- 
Stefan Richter
-=====-===-- -==- ---=-
http://arcgraph.de/sr/
