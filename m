From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv4: add link_filter sysctl
Date: Wed, 18 Mar 2009 22:34:52 -0700 (PDT)
Message-ID: <20090318.223452.113685961.davem@davemloft.net>
References: <20090313161253.0f02da26@nehalam>
	<20090318.182115.43965264.davem@davemloft.net>
	<20090318194239.1adc47d2@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38570
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750827AbZCSFfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:35:05 -0400
In-Reply-To: <20090318194239.1adc47d2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 18 Mar 2009 19:42:39 -0700

> Unfortunately, network management tools expect routers to behave this
> way: WWCD

I understand your concern but I would never approach the specific
problem you stated that way.

If I want to know that the link to the next hop of the router is down,
I'd ping the next hop not that router's interface IP address.  That
is pretty much the stupidest thing I've ever heard of.

Or, if I specifically wanted to diagnose connectivity to "B" I'd
use traceroute and/or work my way back with pings, hop by hop.

People expect Linux to do a lot of things the way other systems do, so
what?  If we have a reasonable way to approach solving a particular
problem, and in this case we certainly do, we gain nothing by adding
the knob besides placating a robot unwilling to learn new things.

Sorry, I'm not applying this.

