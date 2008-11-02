From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: make H-TCP the default congestion control
Date: Sat, 01 Nov 2008 21:29:57 -0700 (PDT)
Message-ID: <20081101.212957.259408012.davem@davemloft.net>
References: <20081030083641.55e936b0@extreme>
	<20081031.005033.172610018.davem@davemloft.net>
	<20081031121625.3c1a463e@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750902AbYKBEaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 00:30:22 -0400
In-Reply-To: <20081031121625.3c1a463e@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 31 Oct 2008 12:16:25 -0700

> The new version of CUBIC is not as tested as H-TCP. Therefore it is
> prudent to make H-TCP the default congestion control for one (or more)
> releases until the new HyStart code has been real world tested.
> 
> This is likely to generate interesting discussion and testing.
> Both H-TCP and CUBIC are robust.  For most users, there will be no
> perceivable difference, but for users with excessively large queues (DSL ISPs)
> H-TCP is more fair. One CUBIC flow fills the queue, and the second
> flow never pushes hard enough to cause fairness.
> 
> For researchers with very high speed networks
> with switches with minuscule queues, CUBIC works better.
> H-TCP sees the packet loss from the small queue and reduces
> sending rate.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I'm not so sure about this logic, regardless of the algorithms
involved.

H-TCP was never the default in any distribution or release that
I know of.  So it's real world exposure is effectively zero,
which is the same as the new CUBIC stuff.

They are effectively, therefore, equivalent choices.

Besides, Koreans are perfect so we actually have nothing to worry
about :-)
