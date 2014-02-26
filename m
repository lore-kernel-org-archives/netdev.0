From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ipv4: ipv6: better estimate tunnel header cut
 for correct ufo handling
Date: Wed, 26 Feb 2014 13:45:58 -0500 (EST)
Message-ID: <20140226.134558.1764489422685253686.davem@davemloft.net>
References: <20140223234805.GE6598@order.stressinduktion.org>
	<20140225.182746.1170300275583266483.davem@davemloft.net>
	<20140226134735.GD24855@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, linux@stwm.de, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, therbert@google.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbaBZSqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 13:46:03 -0500
In-Reply-To: <20140226134735.GD24855@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 26 Feb 2014 14:47:35 +0100

> This bug is present and was reported on v3.13 kernels, so I also would propose
> this for v3.13. I hoped it would be clear from the thread, but should have
> stated this more clearly.
> 
> It really is only appropriate there as this problem was introduced with
> 61c1db7fae21ed ("ipv6: sit: add GSO/TSO support") and cb32f511a70be8
> ("ipip: add GSO/TSO support"), both introduced in v3.13.

Ok, queued up for -stable, thanks.
