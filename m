From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next-2.6] packet: Add GSO/csum offload support.
Date: Fri, 5 Feb 2010 13:14:06 +1100
Message-ID: <20100205021406.GA10651@gondor.apana.org.au>
References: <1265239340.5600.21.camel@w-sridhar.beaverton.ibm.com> <20100205005256.GA9969@gondor.apana.org.au> <1265331730.31059.22.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52694 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756018Ab0BECOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 21:14:12 -0500
Content-Disposition: inline
In-Reply-To: <1265331730.31059.22.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 04, 2010 at 05:02:10PM -0800, Sridhar Samudrala wrote:
> 
> In the case of SOCK_DGRAM reserve is not set and will be 0 and hence
> it is same as calling skb_reset_network_header(skb)

Thanks for the explanation.  The patch looks good to me.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
