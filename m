From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25] [TCP]: Move FRTO checks out from write queue abstraction funcs
Date: Fri, 23 Nov 2007 21:34:28 +0800
Message-ID: <20071123133428.GK18862@gondor.apana.org.au>
References: <Pine.LNX.4.64.0711231422500.24866@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1209 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754876AbXKWNeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 08:34:31 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711231422500.24866@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 02:25:08PM +0200, Ilpo J=E4rvinen wrote:
>=20
> Better place exists in update_send_head (other non-queue related
> adjustments are done there as well) which is the only caller of
> tcp_advance_send_head (now that the bogus call from mtu_probe is
> gone).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Hmm, why don't we just get rid of tcp_advance_send_head?
Or are you planning to start using it again?

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
