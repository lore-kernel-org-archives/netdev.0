From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] ipv6: use timer pending
Date: Mon, 21 Jul 2008 13:21:58 -0700 (PDT)
Message-ID: <20080721.132158.02730153.davem@davemloft.net>
References: <20080721192834.221648982@vyatta.com>
	<20080721192919.971385103@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32865
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754168AbYGUUV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 16:21:58 -0400
In-Reply-To: <20080721192919.971385103@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 21 Jul 2008 12:28:35 -0700

> This fixes the bridge reference count problem and cleanups ipv6 FIB timer management.
> Don't use expires field, because it is not a proper way to test,
> instead use timer_pending().
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, and I'll queue this up for -stable too.

Thanks!
