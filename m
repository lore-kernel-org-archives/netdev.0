From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] IPv4 raw_hdrincl_nomangle sysctl
Date: Thu, 18 Dec 2008 11:52:10 +1100
Message-ID: <20081218005210.GA29247@gondor.apana.org.au>
References: <494964CA.5050109@gmail.com> <20081217.124841.169000877.davem@davemloft.net> <200812180021.00962@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, katterjohn@gmail.com,
	netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32876 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751661AbYLRAwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 19:52:20 -0500
Content-Disposition: inline
In-Reply-To: <200812180021.00962@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 10:21:00PM +0000, R=E9mi Denis-Courmont wrote:
>
> Does SOCK_DGRAM not save userland from crafting the LL header - contr=
ary=20
> to SOCK_RAW?

Right, but you still need to supply the destination MAC address.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
