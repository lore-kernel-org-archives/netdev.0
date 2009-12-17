From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 22:16:20 +0800
Message-ID: <20091217141620.GA32534@gondor.apana.org.au>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <OF32B8811E.870B9515-ON6525768F.003F57BD-6525768F.0040952B@in.ibm.com> <20091217131708.GC8654@ff.dom.local> <OF36B67DA5.E6556DDD-ON6525768F.00498720-6525768F.004CD7A8@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48684 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760083AbZLQOQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 09:16:29 -0500
Content-Disposition: inline
In-Reply-To: <OF36B67DA5.E6556DDD-ON6525768F.00498720-6525768F.004CD7A8@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 07:40:32PM +0530, Krishna Kumar2 wrote:
> 
> I took the numbers from Sridhar's mail before the NAPI patch. I think
> having 280K requeue's in 1 min means that the driver is waking up the
> queue when it should not. The NAPI patch fixes that, but he still
> reported seeing requeue's.

Since we're still in the dark as to why this is happening, it
would be really helpful if we could test 2.6.31's virtio-net
under 2.6.32 or vice versa to determine whether it is a driver
change or a core change that's creating this regression.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
