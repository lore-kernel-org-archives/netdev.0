From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS]: The ip6_fib_timer can work with garbage on net
 namespace stop.
Date: Thu, 24 Apr 2008 01:03:08 -0700 (PDT)
Message-ID: <20080424.010308.62149951.davem@davemloft.net>
References: <480C912E.70900@openvz.org>
	<20080424.011406.109706186.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34925
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751211AbYDXIDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:03:11 -0400
In-Reply-To: <20080424.011406.109706186.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Apr 2008 01:14:06 +0900 (JST)

> In article <480C912E.70900@openvz.org> (at Mon, 21 Apr 2008 17:05:50 +0400), Pavel Emelyanov <xemul@openvz.org> says:
> 
> > The del_timer() function doesn't guarantee, that the timer callback
> > is not active by the time it exits.
> > 
> > Thus, the fib6_net_exit() may kfree() all the data, that is required
> > by the fib6_run_gc(). The race window is tiny, but slab poisoning can
> > trigger this bug.
> > 
> > Using del_timer_sync() will cure this.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> Also suitable for -stable.

I will queue it, thanks.
