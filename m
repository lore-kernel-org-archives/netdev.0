From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS]: The ip6_fib_timer can work with garbage on net
 namespace stop.
Date: Mon, 21 Apr 2008 14:23:15 -0700 (PDT)
Message-ID: <20080421.142315.226236627.davem@davemloft.net>
References: <480C912E.70900@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48965
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758058AbYDUVXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 17:23:13 -0400
In-Reply-To: <480C912E.70900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 21 Apr 2008 17:05:50 +0400

> The del_timer() function doesn't guarantee, that the timer callback
> is not active by the time it exits.
> 
> Thus, the fib6_net_exit() may kfree() all the data, that is required
> by the fib6_run_gc(). The race window is tiny, but slab poisoning can
> trigger this bug.
> 
> Using del_timer_sync() will cure this.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
