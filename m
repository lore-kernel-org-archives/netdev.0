From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 13/21] [TCP]: Store retransmit queue packets in RB tree.
Date: Sun, 2 Dec 2007 11:23:34 +1100
Message-ID: <20071202002334.GA14334@gondor.apana.org.au>
References: <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492973133-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3969 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752918AbXLBAXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 19:23:40 -0500
Content-Disposition: inline
In-Reply-To: <11965492973133-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 02, 2007 at 12:48:08AM +0200, Ilpo J=E4rvinen wrote:
>=20
> This work was mostly done by David S. Miller.

=2E..

> @@ -253,6 +254,8 @@ struct sk_buff {
>  	struct sk_buff		*next;
>  	struct sk_buff		*prev;
>=20
> +	struct rb_node		rb;

Did David really do this? :)

I suppose if we moved this into cb (by growing it by the required amoun=
t)
then at least the new space can be used by others.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
