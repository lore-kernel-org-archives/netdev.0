From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 23:28:39 +1100
Message-ID: <20090203122839.GA9393@gondor.apana.org.au>
References: <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203112431.GA8746@gondor.apana.org.au> <20090203114944.GA21957@ioremap.net> <20090203115313.GA9018@gondor.apana.org.au> <20090203120715.GA22427@ioremap.net> <20090203121209.GA9154@gondor.apana.org.au> <20090203121836.GA23300@ioremap.net> <20090203122535.GB8633@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47292 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752151AbZBCM32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 07:29:28 -0500
Content-Disposition: inline
In-Reply-To: <20090203122535.GB8633@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 01:25:35PM +0100, Willy Tarreau wrote:
>
> > So:
> > 1. copy the whole jumbo skb into fragmented one
> > 2. reduce the MTU
> 
> you'll not reduce MTU of established connections though. And trying to
> advertise MSS changes in the middle of a TCP connection is an awful
> hack which I think will not work everywhere.

Not to mention that Ethernet isn't just IP, so the protocol that
is being used might not have a concept of path MTU discovery at
all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
