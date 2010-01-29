From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6] packet: Add GSO/checksum offload support
	to af_packet sockets
Date: Fri, 29 Jan 2010 21:53:43 +1300
Message-ID: <20100129085343.GB23140@gondor.apana.org.au>
References: <1264537819.24933.122.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58742 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752728Ab0A2Ix5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 03:53:57 -0500
Content-Disposition: inline
In-Reply-To: <1264537819.24933.122.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 26, 2010 at 12:30:19PM -0800, Sridhar Samudrala wrote:
>
> +	if (po->vnet_hdr) {
> +		err = -EINVAL;
> +		if (dev->type != ARPHRD_ETHER)
> +			goto out_unlock;

We shouldn't have Ethernet-specific code in AF_PACKET.  What's
more, just because the device type is Ethernet it doesn't mean
that the packet is going to have an Ethernet header.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
