From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 16/17] d80211: fix monitor interfaces
Date: Fri, 21 Apr 2006 22:57:29 +0200
Message-ID: <20060421225729.34dae18b@griffin.suse.cz>
References: <20060421201147.D4F76482CF@silver.suse.cz>
	<1145651369.3897.33.camel@localhost>
	<20060421224935.5acd79bf@griffin.suse.cz>
	<1145652778.3897.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:19880 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932471AbWDUU5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:57:31 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1145652778.3897.43.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Apr 2006 22:52:58 +0200, Johannes Berg wrote:
> > and this will work - independently of the value of monitor_during_oper.
> > The difference is that in case of monitor_during_oper == 0, you won't
> > probably receive much more frames from mon0 than from sta0. But - you
> > will most likely receive beacons on mon0 and also monitoring headers
> > (prism2 headers presently).
> 
> This I don't understand, doesn't the UI kind of suck as opposed to just
> putting the sta0 device into promisc mode?

In promisc mode, you receive only packets destined to your BSS,
regardless of their source or destination address (so it's similar to
the way promisc works with Ethernet). On monitor interface, you receive
all packets regardless of BSSID.

 Jiri

-- 
Jiri Benc
SUSE Labs
