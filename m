From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 21:06:31 +0800
Message-ID: <20090226130631.GA14125@gondor.apana.org.au>
References: <20090226093902.GA12753@gondor.apana.org.au> <20090226105616.GA5754@ff.dom.local> <20090226115604.GA13592@gondor.apana.org.au> <20090226.041037.134928084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, ash@sevsky.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51109 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751291AbZBZNGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 08:06:43 -0500
Content-Disposition: inline
In-Reply-To: <20090226.041037.134928084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 04:10:37AM -0800, David Miller wrote:
> 
> netpoll supports receiving packets and has a trap handler to eat them
> to avoid packets it is interested in going into the real stack.
> (netpoll_receive_skb, netpoll_rx_skb, etc.)

OK after much head scratching and staring, it turns out that
this is caused by the VLAN path not doing the netpoll check
which would normally drop the packets when a printk is active.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
