From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tcp: ipv6_mapped needs sk_rx_dst_set method
Date: Thu, 09 Aug 2012 21:06:00 -0700 (PDT)
Message-ID: <20120809.210600.638327100706973152.davem@davemloft.net>
References: <20120809160349.d2880b5a.akpm@linux-foundation.org>
	<1344556733.31104.819.camel@edumazet-glaptop>
	<1344557460.31104.863.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab2HJEGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 00:06:01 -0400
In-Reply-To: <1344557460.31104.863.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Aug 2012 02:11:00 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 5d299f3d3c8a2fb (net: ipv6: fix TCP early demux) added a
> regression for ipv6_mapped case.
 ...
> Fix this using inet_sk_rx_dst_set(), and export this function in case
> IPv6 is modular.
> 
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
