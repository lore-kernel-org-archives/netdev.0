From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: skb->xmit_more support
Date: Wed, 08 Oct 2014 11:16:58 -0700
Message-ID: <1412792218.2191.0.camel@jtkirshe-mobl>
References: <1412713823.11091.166.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141008100258.00006afd@intel.com>
	 <20141008.133509.184049487346908540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CaYspNsmUmi31/tXj4YE"
Cc: gregory.v.rose@intel.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, dborkman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10130 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbaJHSRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2014 14:17:02 -0400
In-Reply-To: <20141008.133509.184049487346908540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CaYspNsmUmi31/tXj4YE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-10-08 at 13:35 -0400, David Miller wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Wed, 8 Oct 2014 10:02:58 -0700
>=20
> > On Tue, 7 Oct 2014 13:30:23 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> >> From: Eric Dumazet <edumazet@google.com>
> >>=20
> >> Support skb->xmit_more in i40e is straightforward : we need to move
> >> around i40e_maybe_stop_tx() call to correctly test
> >> netif_xmit_stopped() before taking the decision to not kick the NIC.
> >>=20
> >> Signed-off-by: Eric Dumazet <edumazet@google.com>
> >=20
> > Looks good to me.
>=20
> Jeff, ok for me to apply this directly now?
>=20
> Thanks.

Yes, please do.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-CaYspNsmUmi31/tXj4YE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUNX+aAAoJEOVv75VaS+3O0EEQAJvjDzNkO55s7qVxIu4lSoFU
X+gG2l4oTpATww4QML6LHd9MaXEJ6cyofVST7S295eR5VfRHBtlBYCSQUeJi8E6N
m6tF1mioMVmMIt2XAFgEVcANU1xF1D8DBKQOxjvfVyneqz4F1zlanSnzn8yy+aCF
tcbvUWkVIV9lgFsHwT/eDM4uMdTrIcW22yl272rO/MZ8TlcNiUOKp559iatfokXA
1o/C/QMXDsbWEiVJtwFh3I1bDlvfbBNA6Y/ueAuWAi2rZxNApM3jm1lorPnluUir
yj6DKiesWGXduv/6exlOCMwr3Zg97r7+Wtdua6rkcXTVGoGdWn5MfnaEMVbNYfRV
2ZvB3aFII1nROO29L5bV3ZF3VyLHx2RuKGexzc+ogOOCHA7NuARnhpXV+Refv3i5
PP7/EvgCWNwD9fDirzEkSgugd3UKsbUfw5a9AfPTHUwkNU0/b3ZAJgl/2aPVu1Tk
/5PjR1Okrz9igQh3kb3oo0kfEmSzTp2T+cR8UaoBo3Mk8L7J1hBF5bE9cY2fcpZM
Q+7pbdKf+zxpSH/g/1VKtyb3XXtrpTmLtpSm1b/unAtiz18Ex5fC076Q8A98OA8U
Nv5NB0w/2wF3XQ/SC5FX8oWPJKbiPZbknVix368pjSff99ovMFOF95HzRa+SoCIz
BmES8J21YWF0TAZvX2dg
=loN2
-----END PGP SIGNATURE-----

--=-CaYspNsmUmi31/tXj4YE--
