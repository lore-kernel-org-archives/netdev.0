From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: drop packets with multiple fragmentation
 headers
Date: Tue, 20 Aug 2013 00:12:17 -0700 (PDT)
Message-ID: <20130820.001217.1997350096308784983.davem@davemloft.net>
References: <20130816113007.GD2112@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab3HTHMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 03:12:17 -0400
In-Reply-To: <20130816113007.GD2112@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 16 Aug 2013 13:30:07 +0200

> It is not allowed for an ipv6 packet to contain multiple fragmentation
> headers. So discard packets which were already reassembled by
> fragmentation logic and send back a parameter problem icmp.
> 
> The updates for RFC 6980 will come in later, I have to do a bit more
> research here.
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks.
