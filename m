From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 11:12:33 +0800
Message-ID: <20091217031233.GA26027@gondor.apana.org.au>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912161311.40644.rusty@rustcorp.com.au> <20091216025331.GA13935@gondor.apana.org.au> <200912162315.38802.rusty@rustcorp.com.au> <1261014180.11648.35.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, mst@redhat.com,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34538 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752569AbZLQDMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 22:12:44 -0500
Content-Disposition: inline
In-Reply-To: <1261014180.11648.35.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 05:43:00PM -0800, Sridhar Samudrala wrote:
>
> I had to change virtnet_xmit_poll() to get it working. See below.
> With this change, i don't see any 'queue full' warnings, but requeues
> are still happening at the qdisc level (sch_direct_xmit() finds that
> tx queue is stopped and does requeues).

More importantly how does the performance look?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
