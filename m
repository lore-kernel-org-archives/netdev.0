From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 21:44:08 +0800
Message-ID: <20091217134408.GB31964@gondor.apana.org.au>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au> <20091217114937.GA30503@gondor.apana.org.au> <20091217120856.GA30774@gondor.apana.org.au> <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44473 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935609AbZLQNoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 08:44:16 -0500
Content-Disposition: inline
In-Reply-To: <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 05:57:15PM +0530, Krishna Kumar2 wrote:
> 
> I am confused. Isn't dequeue_skb returning NULL for 2nd - nth skbs
> till the queue is restarted, so how is it broken?

Sorry I didn't read dev_dequeue carefully enough.  Indeed it
correctly checks the queue status so the loop that I thought
was there doesn't exist.

The requeues are probably caused by the driver still.  Was Sridhar
testing Rusty's latest patch?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
