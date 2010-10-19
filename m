From: David Miller <davem@davemloft.net>
Subject: Re: Nested GRE locking bug
Date: Tue, 19 Oct 2010 01:53:03 -0700 (PDT)
Message-ID: <20101019.015303.104063240.davem@davemloft.net>
References: <1287028842.11178.68.camel@localhost>
	<1287029519.2649.108.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	beatrice.barbe@gmail.com, 599816@bugs.debian.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46845
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756596Ab0JSIwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 04:52:40 -0400
In-Reply-To: <1287029519.2649.108.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Oct 2010 06:11:59 +0200

> net-next-2.6 contains a fix for this, adding the perc_cpu
> xmit_recursion limit. We might push it to net-2.6

We need to think a bit more about this.

We are essentially now saying that one can only configure
tunnels 3 levels deep, and no more.

I can guarentee you someone out there uses at least 4,
perhaps more.

And those people will be broken by the new limit.

So putting this into net-2.6 with such a low limit will
be quite dangerous.
