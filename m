From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] IPROUTE: generate compat messages that match
 nla_parse_nested_compat
Date: Thu, 28 Aug 2008 03:02:00 -0700 (PDT)
Message-ID: <20080828.030200.54198413.davem@davemloft.net>
References: <20080828095131.GX20815@postel.suug.ch>
	<20080828.025528.56442281.davem@davemloft.net>
	<20080828095948.GY20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55284
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750780AbYH1KCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 06:02:06 -0400
In-Reply-To: <20080828095948.GY20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 28 Aug 2008 11:59:48 +0200

> * David Miller <davem@davemloft.net> 2008-08-28 02:55
> > He's doing the bogus iproute2 alternative to curing the regression
> > in PRIO and RR that was added to 2.6.26 and 2.6.25.7
> > 
> > That's what this is for.
> > 
> > But see my other email, we'll likely fix this in the kernel.
> 
> The prio scheduler also no longer parses nested attributes, you have
> removed that piece of code when you removed RR. There is nothing to
> fix really.  multiq is currently the only "real" user of
> addattr_nest_compat().

2.6.26 and 2.6.25.7 still have the prio and RR scheduler multiqueue
parts, and we broke them.

See my other reply in the other thread where this discussion
was taking place.
