From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Pull request: Fixes for new ethtool RSS commands
Date: Tue, 03 Jun 2014 02:42:00 +0100
Message-ID: <1401759720.14007.176.camel@deadeye.wl.decadent.org.uk>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
	 <20140602.171314.565532478564496551.davem@davemloft.net>
	 <20140602.172359.1089625839083920695.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-V8N81xtYXl3EjiCLnejy"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49606 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751431AbaFCBmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 21:42:15 -0400
In-Reply-To: <20140602.172359.1089625839083920695.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-V8N81xtYXl3EjiCLnejy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-06-02 at 17:23 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 02 Jun 2014 17:13:14 -0700 (PDT)
>=20
> > From: Ben Hutchings <ben@decadent.org.uk>
> > Date: Mon, 02 Jun 2014 01:57:39 +0100
> >=20
> >> The following changes since commit eb02a272c97b6e25d8e5fcf1ea93923e6f1=
55595:
> >>=20
> >>   driver/net/ethernet/ec_bhf.c: fix sparse warnings (2014-05-14 16:09:=
33 -0400)
> >>=20
> >> are available in the git repository at:
> >>=20
> >>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/net-next.git ethto=
ol-rssh-fixes
> >>=20
> >> for you to fetch changes up to dfe805c14a2018c5a58cfa3921f189703274050=
1:
> >>=20
> >>   ethtool: Check that reserved fields of struct ethtool_rxfh are 0 (20=
14-05-19 01:30:30 +0100)
> >>=20
> >> This addresses several problems I previously identified with the new
> >> ETHTOOL_{G,S}RSSH commands:
> >=20
> > Pulled into net-next, thanks Ben.
>=20
> Actually, it looks like you missed some drivers, please fix this up and
> resubmit:
>=20
> drivers/net/vmxnet3/vmxnet3_ethtool.c:631:2: error: unknown field =E2=80=
=98get_rxfh_indir=E2=80=99 specified in initializer
> drivers/net/vmxnet3/vmxnet3_ethtool.c:631:2: warning: initialization from=
 incompatible pointer type [enabled by default]
> drivers/net/vmxnet3/vmxnet3_ethtool.c:631:2: warning: (near initializatio=
n for =E2=80=98vmxnet3_ethtool_ops.get_rxfh=E2=80=99) [enabled by default]
> drivers/net/vmxnet3/vmxnet3_ethtool.c:632:2: error: unknown field =E2=80=
=98set_rxfh_indir=E2=80=99 specified in initializer
> drivers/net/vmxnet3/vmxnet3_ethtool.c:632:2: warning: initialization from=
 incompatible pointer type [enabled by default]
> drivers/net/vmxnet3/vmxnet3_ethtool.c:632:2: warning: (near initializatio=
n for =E2=80=98vmxnet3_ethtool_ops.set_rxfh=E2=80=99) [enabled by default]
> make[3]: *** [drivers/net/vmxnet3/vmxnet3_ethtool.o] Error 1
> make[2]: *** [drivers/net/vmxnet3] Error 2
> make[2]: *** Waiting for unfinished jobs....

Sorry, I think I must have checked for the old operation names only in
drivers/net/ethernet/.  vmxnet3 is the only other driver implementing
them.

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-V8N81xtYXl3EjiCLnejy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU40n7ue/yOyVhhEJAQpB9Q/+NoHapmox037Yk0qBtiWdZ0YGDtxweNlT
Sm44m9IyYx9K7vHzw5nEzAV/X+YnO/8ioEYq7EaoEMrOxTsCEzjSaQEjGmf1kIyW
GjW3T8r73I/iGUMyDre9dad5sf95JRWbBvD3JqpUjwc3ggmxyN15yOfg1L9m5bua
P/o5TxLf+LSwJoHjoGabDaZKU7QzFk0BeZAx6vfHt6GPx2j7fybpa/5CLlP3wjrf
3ffyqbLa07VGZ3o2tiotoGm/Iu6M7s3h364GESs+qUugrlYm3ilj8fDbhrd62JGr
kHwfMUARO7phBB3cT1fN94RcrrQktd6m0dLL7Ac8uQVfrua2oHiR3/IR9pW3If+l
jGQQ/jGang8AsVuPJS7IIOarYChWGxCUr4AiQDpYV0OL1hcC1oMDOaud3cA7ozbP
YYBEb8Ei5jMitqyrWXhvAXoXQVxOjViPOTEPyQd1fumrRDkkSijYenPL7pJbUp2O
ooixRsoDFU6JAMWBERslSyEPRf4qVd85ztj/9vZmP8e83bKxpswg/AQ8c9qbS2iG
8PfcZMMk8lJKrIEU9ZGr5ITbevjNMl9jiw52R/YUMui7frmrU7JnAFYb80K8orAQ
Jl1cu9AG2HLpZq3+p2JCamraWK/8+cofeptlzInATZlIhAVhZvV7FGzDK5LO89Yt
9uCCz6s4Gnc=
=vht6
-----END PGP SIGNATURE-----

--=-V8N81xtYXl3EjiCLnejy--
