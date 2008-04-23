From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][NETNS]: The ip6_fib_timer can work with garbage on net
 namespace stop.
Date: Thu, 24 Apr 2008 01:14:06 +0900 (JST)
Message-ID: <20080424.011406.109706186.yoshfuji@linux-ipv6.org>
References: <480C912E.70900@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32998 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbYDWQOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 12:14:07 -0400
In-Reply-To: <480C912E.70900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <480C912E.70900@openvz.org> (at Mon, 21 Apr 2008 17:05:50 +0400), Pavel Emelyanov <xemul@openvz.org> says:

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

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Also suitable for -stable.

--yoshfuji
