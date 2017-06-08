From: Sebastian Reichel <sebastian.reichel@collabora.co.uk>
Subject: Re: next-20170608 build: 1 failures 4 warnings (next-20170608)
Date: Thu, 8 Jun 2017 16:53:10 +0200
Message-ID: <20170608145309.cjdtqx23ftaa7xmo@earth>
References: <E1dIuCM-0000cQ-QM@optimist>
 <20170608103231.gmqx6qluzcjwzrst@sirena.org.uk>
 <20170608113326.zo3nqwkbx3k42owz@earth>
 <20170608.101757.1257358800507365931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="sfrhsy5lsszxe4tj"
Cc: broonie@kernel.org, kernel-build-reports@lists.linaro.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:50411 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751469AbdFHOxN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 10:53:13 -0400
Content-Disposition: inline
In-Reply-To: <20170608.101757.1257358800507365931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sfrhsy5lsszxe4tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Jun 08, 2017 at 10:17:57AM -0400, David Miller wrote:
> > On Thu, Jun 08, 2017 at 11:32:31AM +0100, Mark Brown wrote:
> >> On Thu, Jun 08, 2017 at 10:57:50AM +0100, Build bot for Mark Brown wro=
te:
> >>=20
> >> Today's -next fails to build an ARM allmodconfig due to:
> >>=20
> >> > 	arm-allmodconfig
> >> > ../drivers/hsi/clients/ssi_protocol.c:1069:5: error: 'struct net_dev=
ice' has no member named 'destructor'
> >>=20
> >> due to cf124db566e6 (net: Fix inconsistent teardown and release of
> >> private netdev state.) which missed this instance, presumably due to a
> >> combination of it not being in one of the normal networking driver
> >> directories and only being buildable on ARM.
> >=20
> > I assume, that this will be fixed via the net tree.
> > If you Cc me on updated/new patch I will provide Acked-by.
>=20
> It is fixed in the 'net' tree, don't worry about it :-)

https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/?id=3D=
ed66e50d9587fc0bb032e276a2563c0068a5b63a

Looks good, thanks.

-- Sebastian

--sfrhsy5lsszxe4tj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlk5ZNMACgkQ2O7X88g7
+pogUw/+Owwppw7r+xlkq0zhspFoIbeOK81eWd1AMi2kdS5/fsDwhbxlcjAEi04L
qim1x+EaGZITntv2KsnLG8nxFh1VinkKCvrFIxamxsSwPlXx2+un25EinP/gqwUl
pxYRTpUDgIFCDryLmC7sLaLZEv7RBNawX6IY7cCMkla4egb3wcpHoAnTCuKiKlxI
utfS6lNEK/t3yPPVdsl9n1BHp6+deBaIuJUz19+1CEW24XWyWhQEoxcN5Tb7qpvo
ALjUSjwt7ls7JxIrXXyoyxNW+g/SVlfM6brh3KCNJdoU9CTtQKkrwRWa8tKwxhRv
18sMIFGvB7x1BcvVw14S++ta3nz8e1C6k2hNhJSNVcvaloTut2Zk5m7cQcaj0UES
yOsMfjuZbpSmly03HaxoaHkzw7rblAPjzhXFgDfOVMTpAILtp7SWvW7tDPfUmXXc
sSvX8qltKoZP5JLeYQGb6ygP+spCXrnYqIskZW/E3AxEHufn1R1Cn4PdyC4f8Y2w
qk5Ay+qfMliBLg1xiPxENug3wZaxkjEdP5G+Lxhdbh4Ix/5NZXT3Hry4gaKmna9w
vmYfzDBSodUFBYCpn+HC1Qg77YWG2ZAQoSZrIVK+yWWOiXpJnhfdlvOJdKNwIW7/
ULBBz5d1FIJkZKPj3YmoREl50d4A4jWWfXx4GWUwDayiNG/+juQ=
=S//p
-----END PGP SIGNATURE-----

--sfrhsy5lsszxe4tj--
