From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware
 restart.
Date: Sun, 21 Sep 2008 11:35:13 -0700
Message-ID: <20080921113513.16677c4e@infradead.org>
References: <20080921172316.GA6306@2ka.mipt.ru>
	<20080921110422.1d010b96@infradead.org>
	<20080921182835.GA11473@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ipw2100-devel@lists.sourceforge.net,
	linux-wireless@vger.kernel.org, yi.zhu@intel.com,
	reinette.chatre@intel.com, jgarzik@pobox.com,
	linville@tuxdriver.com, davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35604 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbYIUSfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 14:35:12 -0400
In-Reply-To: <20080921182835.GA11473@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 21 Sep 2008 22:28:38 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Sun, Sep 21, 2008 at 11:04:22AM -0700, Arjan van de Ven
> (arjan@infradead.org) wrote:
> > so now you go from an occasional burp to having nothing at all.
> > How about you run with this patch on your own machine only?
> 
> And how else user can get attention to the problem which is not fixed
> by the vendor? 

... or the community

> We close our eyes and there is no problem, since we do
> not see it. I just brought a lamp: no user can see that essentially
> driver is broken so he can run it on his own risk.
> 
> > or.. since you say a reload of the driver fixes it.. why don't you
> > make a patch for the driver that does basically the actions of a
> > reload automatically when the driver detects the issue?
> > (and stick a WARN_ON in for good measure so that kerneloops.org can
> > start tracking these burps)
> 
> It stops after several seconds (or packets?). Sometimes (but rarely)
> it works several minutes, sometimes it fires above dmesg line and
> continues to work, sometimes it fires it for a while and then stops
> writing it, although driver does not send or receive anything (at
> least ifconfig counters do not change).

again.. so how about you detect this condition and do, in the driver
code, the equivalent of rmmod/insmod to the hardware. I'm sure people
who have the hardware would appreciate that type of patch a lot more
than the one you sent out.




-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
