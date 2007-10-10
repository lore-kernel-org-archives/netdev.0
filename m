From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [IPV6] Defer IPv6 device initialization until a valid qdisc is specified
Date: Wed, 10 Oct 2007 09:32:35 +0800
Message-ID: <E1IfQR9-0006j8-00@gondolin.me.apana.org.au>
References: <20071009162158.f25d4fdb.mitch@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: mitch@linux.vnet.ibm.com (Mitsuru Chinen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2123 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753356AbXJJBdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 21:33:13 -0400
In-Reply-To: <20071009162158.f25d4fdb.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitsuru Chinen <mitch@linux.vnet.ibm.com> wrote:
> To judge the timing for DAD, netif_carrier_ok() is used. However,
> there is a possibility that dev->qdisc stays noop_qdisc even if
> netif_carrier_ok() returns true. In that case, DAD NS is not sent out.
> We need to defer the IPv6 device initialization until a valid qdisc
> is specified.

Is this really necessary?

What if this is plugged into a switch that has nothing else
connected? Should you also wait for something to be connected
to the switch?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
