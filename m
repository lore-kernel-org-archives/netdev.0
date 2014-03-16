From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 1/4] net: add name_assign_type netdev attribute
Date: Sun, 16 Mar 2014 19:17:09 +0000
Message-ID: <1394997429.15764.116.camel@deadeye.wl.decadent.org.uk>
References: <1394990490-1076-1-git-send-email-dh.herrmann@gmail.com>
	 <1394990490-1076-2-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-t6iSqRIB9XFun5VjX3F7"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Herrmann <dh.herrmann@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394990490-1076-2-git-send-email-dh.herrmann@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-t6iSqRIB9XFun5VjX3F7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-03-16 at 18:21 +0100, David Herrmann wrote:
[...]
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -74,6 +74,11 @@ void netdev_set_default_ethtool_ops(struct net_device =
*dev,
>  #define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
>  #define NET_RX_DROP		1	/* packet dropped */
> =20
> +/* interface name assignment types */
> +#define NET_NAME_ENUM		0	/* enumerated by kernel (default) */
> +#define NET_NAME_USER		1	/* provided by user-space */
> +#define NET_NAME_RENAMED	2	/* renamed by user-space */
[...]

I think these definitions should be put in a UAPI header.  Even if the
names don't end up being used by userland, that would make it clear that
the numbers are a stable ABI.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-t6iSqRIB9XFun5VjX3F7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyX4tee/yOyVhhEJAQrgGw//WphR8tzozaVHMuvgPNNscsBZQ+kw3c1S
wBUVbTbfYmylS4oSI48yxJpPZOB8tu5K6dxWR806oUJYda0v37sZwaBhYtb666/W
TdjTY9614FGxL1/gU9UfPQwEjHCXNujdq7Ylj/68u+CzSjnHMSfXryOV6IvGNmJD
9ejfclWRJC3eUZ4dVFbeN8X7/dLvQ6EOgaF03jbhqH9dXd/xMtHlP3RDZ7hK7xfK
KUrIXPJhDh8avjO5CmzVODVl/SHNFBvZtWd+yOJNFK6uZfNJHP+4uF7x4m+c0DGq
pQoj+rkxmT16eo9NaSd//R4c+Iqgzp+oVMZT8r9xI8BAxHZ7gU1XDzT8/N6ez3qj
Xb4wEFwgw7OCpSCZzVyDvKvDVZiP5PVfRP0PcmUBMgB7CxnboTw3DKbQP/YcfZJs
6I4Qx4Exdr3CxMRm3StVD2uG5D0MjmMPucfDs1E07837knpqrJVKuYw0s7SntSud
M8oXr0E7BZkTzGvjlxZIMj5jrmAegIhjzTAeeIauhpp3dYhYtxWFRRFgCgF5zLnO
Rl8HXYzWH02HN2EMnuqy2R7i/8noQQMTcYeMozyddXduV+NyvkprA4fmW+D6jerv
BnKemsl0C0mw3lRUcGM3yThtb9+RTbCjdU9EDAqq3s0E3VbfCDaCuOh7bL9Ut1o3
t1BVW0DIHlQ=
=uFI+
-----END PGP SIGNATURE-----

--=-t6iSqRIB9XFun5VjX3F7--
