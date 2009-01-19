From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Tue, 20 Jan 2009 08:24:43 +1100
Message-ID: <20090119212443.GC6609@gondor.apana.org.au>
References: <20090119061420.GB12946@1wt.eu> <20090118.221908.47032075.davem@davemloft.net> <20090119101924.GA1881@gondor.apana.org.au> <20090119.125941.240930524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: w@1wt.eu, jarkao2@gmail.com, zbr@ioremap.net, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36930 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752433AbZASVZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 16:25:26 -0500
Content-Disposition: inline
In-Reply-To: <20090119.125941.240930524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2009 at 12:59:41PM -0800, David Miller wrote:
.
> And the difference between 64 and IPV4+TCP header len becomes the
> payload, don't you see? :-)
> 
> myri10ge just pulls min(64, skb->len) bytes from the SKB frags into
> the linear area, unconditionally.  So a small number of payload bytes
> can in fact end up there.

Ah, I thought they were doing a precise division.  Yes pulling
a constant length will trigger it if it's big enough.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
