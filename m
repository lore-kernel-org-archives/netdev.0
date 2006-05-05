From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: [PATCH] bcm43xx-d80211: proper implementation of virtual interface
 support
Date: Fri, 5 May 2006 07:45:09 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0605050738240.21178@p15091797.pureserver.info>
References: <200605012135.00895.mb@bu3sch.de> <20060502132037.059a7cb2@griffin.suse.cz>
 <e3dkfd$pc5$1@sea.gmane.org> <200605042256.02333.IvDoorn@gmail.com>
 <20060505002215.1972e12b@logostar.upir.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ivo van Doorn <ivdoorn@gmail.com>,
	Marcus Better <marcus@better.se>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:49596 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1750972AbWEEFpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 01:45:18 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060505002215.1972e12b@logostar.upir.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The actual problem is with receiving. ACK frames need to be sent exactly
> after SIFS interval (10 or 16 microseconds depending on a PHY, +/- 10%)
> after last bit of the frame was received. This means it cannot be done in a
> software. You need to tell the hardware about MAC address you are using and
> hardware will ACK all frames destined to that address (well, actually only
> that received with valid FCS, but it doesn't matter). And most hardware
> don't allow to specify more MAC addresses.
> 
>  Jiri

Good explanation. ZD1211 allows to specify a second RX address, I
wondered, what this is good for. So for ZD1211 we could support
two virtual interfaces. However in AP mode one virtual device
would have to send the beacons on its own. But there could be also
support for one interface in AP and the other in STA mode.

Uli
-- 
Ulrich Kunitz - kune@deine-taler.de
