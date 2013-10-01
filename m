From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: gre: correct calculation of max_headroom
Date: Mon, 30 Sep 2013 22:04:50 -0700 (PDT)
Message-ID: <20130930.220450.1121984305211620922.davem@davemloft.net>
References: <20130929034050.GB8602@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab3JAE5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 00:57:45 -0400
In-Reply-To: <20130929034050.GB8602@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 29 Sep 2013 05:40:50 +0200

> gre_hlen already accounts for sizeof(struct ipv6_hdr) + gre header,
> so initialize max_headroom to zero. Otherwise the
> 
> 	if (encap_limit >= 0) {
> 		max_headroom += 8;
> 		mtu -= 8;
> 	}
> 
> increments an uninitialized variable before max_headroom was reset.
> 
> Found with coverity: 728539
> 
> Cc: Dmitry Kozlov <xeb@mail.ru>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
