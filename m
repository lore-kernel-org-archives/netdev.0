From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 0/2] ixgbe: macvlan fixes
Date: Fri, 08 Nov 2013 04:39:42 -0800
Message-ID: <1383914382.2365.34.camel@jtkirshe-mobl>
References: <20131108084654.6935.36501.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-stwK0yM0zV8xJvvkI26K"
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56686 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822Ab3KHMjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 07:39:44 -0500
In-Reply-To: <20131108084654.6935.36501.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-stwK0yM0zV8xJvvkI26K
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-08 at 00:50 -0800, John Fastabend wrote:
> Two additional fixes for ixgbe l2 forwarding acceleration. One
> was reported by kbuild build bot and the second after hardening
> my test scripts.
>=20
> Typically I would send ixgbe fixes through JeffK's tree but I
> know a few people who are looking at the feature in their setup's=20
> so wanted to be sure the patches were visible.

I told John to go ahead and send these patches directly to netdev, so
that Dave can pick these up before he pushes his net-next to Linus.

>=20
> For reference the ixgbe accelerated macvlan patch is here:
>=20
> commit 2a47fa45d4dfbc54659d28de311a1f764b296a3c
> Author: John Fastabend <john.r.fastabend@intel.com>
> Date:   Wed Nov 6 09:54:52 2013 -0800
>=20
>     ixgbe: enable l2 forwarding acceleration for macvlans
>=20
> Thanks,
> John
>=20
> ---
>=20
> John Fastabend (2):
>       ixgbe: fix build err, num_rx_queues is only available with CONFIG_R=
PS
>       ixgbe: deleting dfwd stations out of order can cause null ptr deref
>=20
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   24 ++++++++++++++++---=
-----
>  1 file changed, 16 insertions(+), 8 deletions(-)
>=20



--=-stwK0yM0zV8xJvvkI26K
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSfNuOAAoJEOVv75VaS+3OCy0P/0HvBspVei92q+Jf9MlDGHUn
hInrn4qYQHaMclnFBeKzXRBTHGTwM7sLcpukIkMFjfeEwAOZiBOciTQ5zoAT0aYi
nmaWylZ1awA67hvG1Sq/7CRCCZ1To729T6nnhLK2Wi7t+AYZTvNw3Upj8Bzh3s2Q
H1aaAUZJfs7/C9Ozdmt6/YNx7UkGytSHmvvAgVWZ1v8wS3Sio/qrZeScoIhQAqjB
ohZdyJ2BEdCWBCQqzYzl4mjPvSg7e6n++W2nYSUQgyQtjDFmeA07f0ANwUmfzF0Q
aVhjHEz8Fz46Sp2HxI9jFnNQe2Gyvm16h0NjcVJkgv08EEduOiV4DiCvcoHPICzo
6t9A6uTmPvPu2KumrwSEa6Yd8UZ8Kscir3t4Q+Pvj4wFszTMMBbeoBN7B2rni8j5
4xSN+2ICQ50ycZiUOEeemDoLunV9K4F8RZe6CKHWSs2doCKvHR2GTtsYUwX+s3QE
RV65lhy2ccIfYHk5QISgD//5nPDjm9gAkH+8zuaZRhPwYoKCeBIxDD8SqwfP0pfn
2j813tI8ZDrTGlO3KR8HkDhY1jmSShmF+6014AGF0Lfje1U6hDnGNaguuqzwJEM+
N6NGeFIO/f8ZQyxLMvDBr7PvaSbFU0W7njHgeaUMo6E/d+onKUTDiED0H0Ajf5pp
zLvwUReOxcxWzPU0hgJ3
=mWkm
-----END PGP SIGNATURE-----

--=-stwK0yM0zV8xJvvkI26K--
