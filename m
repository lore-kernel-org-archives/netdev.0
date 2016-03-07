From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: macb: Fix more coding style issues
Date: Mon, 07 Mar 2016 13:49:24 -0500 (EST)
Message-ID: <20160307.134924.1763924827140423427.davem@davemloft.net>
References: <1457367460-9123-1-git-send-email-moritz.fischer@ettus.com>
	<1457367460-9123-3-git-send-email-moritz.fischer@ettus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: moritz.fischer@ettus.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbcCGSt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 13:49:27 -0500
In-Reply-To: <1457367460-9123-3-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moritz Fischer <moritz.fischer@ettus.com>
Date: Mon,  7 Mar 2016 08:17:38 -0800

> @@ -945,6 +943,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
>  static int macb_rx(struct macb *bp, int budget)
>  {
>  	int received = 0;
> +	int dropped;
>  	unsigned int tail;
>  	int first_frag = -1;
>  
> @@ -968,7 +967,6 @@ static int macb_rx(struct macb *bp, int budget)
>  		}
>  
>  		if (ctrl & MACB_BIT(RX_EOF)) {
> -			int dropped;
>  			BUG_ON(first_frag == -1);
>  
>  			dropped = macb_rx_frame(bp, first_frag, tail);

I totally disagree with moving local variable declarations up to the
top-most scope.

It is always best to keep them in the inner-most scope.

This is also not even mentioned in your commit message at all.
