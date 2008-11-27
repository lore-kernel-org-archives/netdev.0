From: Willy Tarreau <w@1wt.eu>
Subject: Re: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x17e() with tg3 network
Date: Thu, 27 Nov 2008 06:16:59 +0100
Message-ID: <20081127051659.GA26057@1wt.eu>
References: <20081120184310.GB27712@xw6200.broadcom.net> <20081120212637.GB23844@1wt.eu> <20081120215318.GB27907@xw6200.broadcom.net> <20081124132744.GB24851@1wt.eu> <20081124215247.GA29696@1wt.eu> <20081125015223.GA9151@xw6200.broadcom.net> <20081125053128.GA32426@1wt.eu> <20081125175413.GA9808@xw6200.broadcom.net> <20081126211220.GA22374@1wt.eu> <20081126225421.GA8906@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Heflin <rogerheflin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1401 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890AbYK0FRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2008 00:17:09 -0500
Content-Disposition: inline
In-Reply-To: <20081126225421.GA8906@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 26, 2008 at 02:54:21PM -0800, Matt Carlson wrote:
(...)
> > I've run a new test on a switch I have here at home (another el-cheapo,
> > non-manageable 100 Mbps, netgear this time). Unfortunately I cannot
> > reproduce the problem at all. I have disabled FC on my laptop, it did
> > not have any effect.
> 
> Disabling FC should have a positive effect, not a negative one.  It
> might be the case that the switch does not advertise nor support FC.  If
> that is true, you might not be able to repro the problem no matter what
> you did (if your problem is what I think it is).  Can you check your
> link messages and see if it really is negotiated to off?  (I see the
> message above, but I don't think that is with the current switch.)

yes the switch does advertuse FC :

willy@wtap:~$ dmesg|grep eth0
eth0: Tigon3 [partno(BMC5705mA3) rev 3003 PHY(5705)] (PCI:33MHz:32-bit) 10/100/1000Base-T Ethernet 00:0d:9d:91:ef:24
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] WireSpeed[0] TSOcap[1]
eth0: dma_rwctrl[763f0000] dma_mask[64-bit]
tg3: eth0: Link is up at 100 Mbps, full duplex.
tg3: eth0: Flow control is on for TX and on for RX.

> > I have disabled auto-neg and manually forced the
> > speed to 100/Full on my laptop, and could not reproduce the problem
> > either (though the speed was much lower due to the switch obviously
> > negociating 100/Half when not seeing my NWay frames).
> 
> Yes.  If you force the link, both sides must be forced.  The switch
> rightly assumes HD when bringing the link up.

I know ;-) but not seeing the problem, I started to suspect that the other
switch was a little bit ill and tried to reproduce some problems I might
incidently have been encountering on it.

Regards,
Willy

