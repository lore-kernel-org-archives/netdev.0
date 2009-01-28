From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6 multicast routing
Date: Tue, 27 Jan 2009 22:39:02 -0800 (PST)
Message-ID: <20090127.223902.45013943.davem@davemloft.net>
References: <20090120200248.GA13928@boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fred.l.templin@boeing.com
To: thomas.goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751866AbZA1GjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 01:39:04 -0500
In-Reply-To: <20090120200248.GA13928@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Goff <thomas.goff@boeing.com>
Date: Tue, 20 Jan 2009 12:02:48 -0800

>   - Enable/disable IPv6 multicast forwarding on the corresponding
>     interface when a routing daemon adds/removes a multicast virtual
>     interface.

Since Hideaki-san is being unresponsive I looked at this patch again
so I can apply it, or at least part of it, to get the bugs fixed.

I disagree with his objection to the mc_forwarding changes here, they
are correct and in fact desirable.  They are desirable since without
this we have yet another disconnect between ipv4 and ipv6 behavior.

We already have way too many of those.

Every time I notice a behavior difference between our ipv4 and ipv6
stack I almost believe there is an active conspiracy to make the
transition to ipv6 as difficult as possible :-)

So I'm going to apply this patch as-is, with the addition of making
the mc_forwarding sysctl read-only (perms 0444) as it is in ipv4.
