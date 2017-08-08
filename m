From: "Dmitry V. Levin" <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v06 15/36] uapi linux/socket.h: include sys/socket.h in
 user space
Date: Wed, 9 Aug 2017 02:00:42 +0300
Message-ID: <20170808230041.GG10552@altlinux.org>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
 <20170806164428.2273-16-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="YH9Qf6Fh2G5kB/85"
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170806164428.2273-16-mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--YH9Qf6Fh2G5kB/85
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 06, 2017 at 06:44:06PM +0200, Mikko Rapeli wrote:
> This libc header has sockaddr definition in user space.
>=20
> Fixes user space compilation errors like these from kernel headers includ=
ing
> only linux/socket.h:
>=20
> error: field =E2=80=98ifru_addr=E2=80=99 has incomplete type
> struct sockaddr ifru_addr;
> error: field =E2=80=98_sockaddr=E2=80=99 has incomplete type
> struct sockaddr  _sockaddr;
> error: invalid application of =E2=80=98sizeof=E2=80=99 to incomplete type=
 =E2=80=98struct sockaddr=E2=80=99
>=20
> With this following uapi headers now compile in user space:
>=20
> rdma/rdma_user_rxe.h
> linux/vm_sockets.h
> linux/ncp_fs.h
> linux/nfc.h
> linux/phonet.h
>=20
> Signed-off-by: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Dmitry V. Levin <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>
> ---
>  include/uapi/linux/socket.h | 4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/include/uapi/linux/socket.h b/include/uapi/linux/socket.h
> index 76ab0c68561e..8a81197cc08b 100644
> --- a/include/uapi/linux/socket.h
> +++ b/include/uapi/linux/socket.h
> @@ -1,6 +1,10 @@
>  #ifndef _UAPI_LINUX_SOCKET_H
>  #define _UAPI_LINUX_SOCKET_H
> =20
> +#ifndef __KERNEL__
> +#include <sys/socket.h>
> +#endif

This is scary because of infamous libc vs uapi interoperability issues.
Couldn't we fix affected headers instead?


--=20
ldv

--YH9Qf6Fh2G5kB/85
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJZikKZAAoJEAVFT+BVnCUIIioQAO1QoCKbh1o/nx81/ZFTnaxo
Lw5FU435rQgyUCAaAEvjsa90Jm6zBgTNCxGttiHS8jMMZFSFXMCFsJg55eptmtta
t1oszNJrTFoQPz9KK7wSG1uqygOeAxbC96XlxOe2CrcxugwP1Z+XNXUlJK4Dy38G
r7f6VgwEci+J2W4kzCu5rMMBflEepW+AmivKx2YiSxjZWanCTNzKvQxJiWLNk+bb
KjOLFkpxg2JYaUa3qsTtuOSumZae5ROYNOTzR7XmZX3ztbdOsQxTOul9VPJ4L44K
yK18+C/MUopJiLpynaOFuqR/PW2V9JJxrcHcOrjPWngIAv9Q+T/CWeWQB4lVRZGX
kS4A/+YjpC9hGH32Wf62iwiwd92LOzGLfsWdcG2aniQZxxKbzOy/+lwKhu2aLU+e
Aq+EAn4pNH2dZTdgZMrAsg08lGfKetDpd5pQKj6qHOcaH6e/KuBSuyRtY7o5fyY1
8255JhM63kxsHGnNrBUPRxcsP5kGklvYAUMG3O8up6AtE7keyNs/WxB4l5YB33dl
CTiwCmFWcHSfcJ1HuuhhmoBQSJjzgW4Feb+aTo4NQbGlgPOLP3e9FgGv/ZyxCjxJ
vDwMLc4SkpjP5eoLteoz6/B7QKU3YCjQgy46WTTiuCqvZgjqKwtCO8uJciJZi/YD
O2/gw9Hnk8govRuHZmHp
=5ZlZ
-----END PGP SIGNATURE-----

--YH9Qf6Fh2G5kB/85--
