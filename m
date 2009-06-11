From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: virtio-net header alignment
Date: Fri, 12 Jun 2009 06:50:03 +1000
Message-ID: <20090611205003.GA8677@gondor.apana.org.au>
References: <OF1B881599.F1B4A2EF-ON802575BB.0036EA40-802575BC.0041BFB5@au1.ibm.com> <200905251601.29327.rusty@rustcorp.com.au> <1243268223.32745.25.camel@blaa> <20090610051227.GB16563@gondor.apana.org.au> <1244743266.9669.64.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark McLoughlin <markmc@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Danielius Kudinskas <kudinskas@uk.ibm.com>,
	aliguori@linux.vnet.ibm.com, Paul T Knowles <pablo@uk.ibm.com>,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58832 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752165AbZFKUuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 16:50:13 -0400
Content-Disposition: inline
In-Reply-To: <1244743266.9669.64.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 11:01:06AM -0700, Sridhar Samudrala wrote:
>
> I think this fixes the old RX path rather than the mergeable RX path.
> try_fill_recv_maxbufs() is called from try_fill_recv()
> 
>         if (!vi->mergeable_rx_bufs) {
>                 try_fill_recv_maxbufs(vi);
>                 return;
>         }

Yes you're right.  We should do s/mergeable/non-mergeable/ in the
changelog :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
