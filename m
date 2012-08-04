From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed
 out
Date: Sat, 4 Aug 2012 14:22:37 +0200
Message-ID: <20120804142237.44060164@stein>
References: <20120501182405.3dda59b9@stein>
	<20120501172748.GA17117@electric-eye.fr.zoreil.com>
	<20120501200423.6804dcf0@stein>
	<20120501200403.GA20763@electric-eye.fr.zoreil.com>
	<20120503204813.65468df7@stein>
	<20120602111335.0b94fb59@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:51227 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab2HDMWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 08:22:41 -0400
In-Reply-To: <20120602111335.0b94fb59@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jun 02 Stefan Richter wrote:
> I haven't had time to look further into it yet.  Just two minor findings:
> 
> (a) After update from 3.4-rc5 to 3.4, the problem persisted.
> 
> (b) Later I noticed that silent file corruptions on FireWire disks happened
> and happen under 3.4-rc5 and 3.4, so I reverted into 3.3.1 which fixed
> that issue.  Furthermore, since 6 days uptime of 3.3.1, the eth0 (r8169)
> transmit queue time-out did never occur.

After a month uptime of 3.3.1 without any problems, I rebooted into 3.5
six days ago.  The frequent "r8169 0000:0b:00.0: eth0: link up" messages
which I got with 3.4-rc5 and 3.4 no longer happen.  Whatever was wrong
with my system, it no longer is.  Either 3.5 fixed it or it was an issue
external to the kernel or even external to the PC.
-- 
Stefan Richter
-=====-===-- =--- --=--
http://arcgraph.de/sr/
