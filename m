From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: reserve space for IFLA_BRPORT_FAST_LEAVE
Date: Tue, 12 Mar 2013 05:39:54 -0400 (EDT)
Message-ID: <20130312.053954.330375189080203774.davem@davemloft.net>
References: <20130311165217.760e80fe@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236Ab3CLJjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 05:39:42 -0400
In-Reply-To: <20130311165217.760e80fe@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 11 Mar 2013 16:52:17 -0700

> The bridge multicast fast leave feature was added sufficient space
> was not reserved in the netlink message. This means the flag may be
> lost in netlink events and results of queries.
> 
> Found by observation while looking up some netlink stuff for discussion with Vlad.
> Problem introduced by commit c2d3babfafbb9f6629cfb47139758e59a5eb0d80
> Author: David S. Miller <davem@davemloft.net>
> Date:   Wed Dec 5 16:24:45 2012 -0500
> 
>     bridge: implement multicast fast leave
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> ---
> Should go to net and stable for 3.8.X

Applied and queued up for -stable.
