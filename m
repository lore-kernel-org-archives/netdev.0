From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netns: timer allocation
Date: Mon, 21 Jul 2008 13:47:39 -0700 (PDT)
Message-ID: <20080721.134739.262598027.davem@davemloft.net>
References: <20080721133037.7b904ddb@extreme>
	<20080721.133337.36896785.davem@davemloft.net>
	<20080721134426.6769f40c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40837
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750724AbYGUUrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:47:39 -0400
In-Reply-To: <20080721134426.6769f40c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Jul 2008 13:44:26 -0700

> FIB timer list is a trivial size structure, avoid indirection and just
> put it in existing ns.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Applies to net-next-2.6 (after PATCH 1)

I've applied patch 1, and it still does not apply.

fib6_start_gc() has the __inline__ tag in my tree, in
your patch it does not.

