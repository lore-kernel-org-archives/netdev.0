From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH net-next v8 02/19] test_bitmap: unit tests for
 lib/bitmap.c
Date: Sat, 13 Feb 2016 01:39:03 +0000
Message-ID: <1455327543.2801.79.camel@decadent.org.uk>
References: <1455064168-5102-1-git-send-email-ddecotig@gmail.com>
	 <1455064168-5102-3-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dMEmN+NpsyqIDHiwxqFo"
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Ed Swierk <eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org>,
	Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
To: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455064168-5102-3-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-dMEmN+NpsyqIDHiwxqFo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-09 at 16:29 -0800, David Decotigny wrote:
> From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
>=20
> This is mainly testing bitmap construction and conversion to/from u32[]
> for now.
>=20
> Tested:
> =C2=A0 qemu i386, x86_64, ppc, ppc64 BE and LE, ARM.
>=20
> Signed-off-by: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
[...]
> diff --git a/tools/testing/selftests/lib/bitmap.sh b/tools/testing/selfte=
sts/lib/bitmap.sh
> new file mode 100644

This needs to have mode 755.

Ben.

> index 0000000..2da187b
> --- /dev/null
> +++ b/tools/testing/selftests/lib/bitmap.sh
> @@ -0,0 +1,10 @@
> +#!/bin/sh
> +# Runs bitmap infrastructure tests using test_bitmap kernel module
> +
> +if /sbin/modprobe -q test_bitmap; then
> +	/sbin/modprobe -q -r test_bitmap
> +	echo "bitmap: ok"
> +else
> +	echo "bitmap: [FAIL]"
> +	exit 1
> +fi
--=20
Ben Hutchings
Sturgeon's Law: Ninety percent of everything is crap.
--=-dMEmN+NpsyqIDHiwxqFo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVr6JN+e/yOyVhhEJAQoreg/8CyAqnMX0OsvT/Kq3OZbYtJ+ox8k0w7lY
QF1kUm532EjcM+eS0ebXuzngeuty2jMLnJ7d4jI6ZtMqCVt5jY4vxvsELPbYut3W
zFVW1WRatPwQA7aa4TUDprR5CuvYqpEp+EVoVUdoMRIgBgOSHHEJJSS1E2Esm4IY
7rtk1thYjbSSXqEFSR5SvVVZ+E8gkh5Awkmr2t67oxhw2aU6kzDq4TD4NP/6OeXu
OFx+hCh7BCu3kkUdkVswWvISiDbXcgKy7khDcAJSI6pvjmMz13Sl9UEOdsqwV/H9
5BRQM4FXyG6Mmc1u6M6vIwWKL5DNcstr0Zp9WA8xwkFimdA/uphCONzWTb4PQZ41
Y0PkQ3qbvAsPsuCyKIxAKi815RzYCbiUn1nhLgXvmJVCw5NHD3lkjJjqh4ejaFIP
nyUOpCJWLPeKAxmH0P1C4827mGJCAbd9zUEjamWqJ6E+NhjyTW7u6VI9yAqQv9oQ
T5cwgec4O2trPqTD2JYLxeXPTtiJQxIBh8ofW9s1V3cdIw5v3or3t2JRvKwNIy2Y
kgXpjr433jhbrxL+cgwX9bRzOmbKlK1xvJpzVze+SO7Vay8tnqlHQu3R5eoNASWs
1jNTYHbo0ARZMMqZDpS0vIAvoBJLG7oBir6qjj2NYT6aby24No5BLNALr8KZMi7X
EFKHaJ7Brcg=
=hORQ
-----END PGP SIGNATURE-----

--=-dMEmN+NpsyqIDHiwxqFo--
