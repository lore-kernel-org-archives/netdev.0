From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 13:19:48 +0000
Message-ID: <20090226131948.GB6294@ff.dom.local>
References: <20090226093902.GA12753@gondor.apana.org.au> <20090226105616.GA5754@ff.dom.local> <20090226115604.GA13592@gondor.apana.org.au> <20090226.041037.134928084.davem@davemloft.net> <20090226130631.GA14125@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ash@sevsky.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:49526 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbZBZNT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 08:19:56 -0500
Received: by bwz26 with SMTP id 26so497730bwz.37
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 05:19:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090226130631.GA14125@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2009 at 09:06:31PM +0800, Herbert Xu wrote:
> On Thu, Feb 26, 2009 at 04:10:37AM -0800, David Miller wrote:
> > 
> > netpoll supports receiving packets and has a trap handler to eat them
> > to avoid packets it is interested in going into the real stack.
> > (netpoll_receive_skb, netpoll_rx_skb, etc.)
> 
> OK after much head scratching and staring, it turns out that
> this is caused by the VLAN path not doing the netpoll check
> which would normally drop the packets when a printk is active.

Yes, nice catch/scratch!

Cheers,
Jarek P.
