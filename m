From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH 2/3] net: wireless: b43: Fixed Pointer issue
Date: Sun, 18 Oct 2015 11:21:02 +0200
Message-ID: <20151018112102.0a63869c@wiggum>
References: <1445122898-5810-1-git-send-email-paulmcquad@gmail.com>
	<1445122898-5810-2-git-send-email-paulmcquad@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/NCy0_TKkwwBoy=S2._9M=E5"; protocol="application/pgp-signature"
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, mike.looijmans-Oq418RWZeHk@public.gmane.org,
	cengelma-RbZlAiThDcE@public.gmane.org, khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul McQuade <paulmcquad-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445122898-5810-2-git-send-email-paulmcquad-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--Sig_/NCy0_TKkwwBoy=S2._9M=E5
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 18 Oct 2015 00:01:37 +0100
Paul McQuade <paulmcquad-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> Moved around pointer to avoid ERROR
>=20
> Signed-off-by: Paul McQuade <paulmcquad-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wireless/b43/dma.h  | 14 +++++++-------
>  drivers/net/wireless/b43/main.c |  6 +++---
>  drivers/net/wireless/b43/main.h |  2 +-
>  drivers/net/wireless/b43/xmit.h |  2 +-
>  4 files changed, 12 insertions(+), 12 deletions(-)
> =20
>  enum b43_dmatype {
> diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/m=
ain.c
> index 2849070..040caa4 100644
> --- a/drivers/net/wireless/b43/main.c
> +++ b/drivers/net/wireless/b43/main.c
> @@ -364,7 +364,7 @@ static struct ieee80211_supported_band b43_band_2ghz_=
limited =3D {
> =20
>  static void b43_wireless_core_exit(struct b43_wldev *dev);
>  static int b43_wireless_core_init(struct b43_wldev *dev);
> -static struct b43_wldev * b43_wireless_core_stop(struct b43_wldev *dev);
> +static struct b43_wldev *b43_wireless_core_stop(struct b43_wldev *dev);
>  static int b43_wireless_core_start(struct b43_wldev *dev);
>  static void b43_op_bss_info_changed(struct ieee80211_hw *hw,
>  				    struct ieee80211_vif *vif,


Can we have a sane commit message, please?
This is not an 'error' or an 'issue'. It's purely cosmetical and coding
style related.

--=20
Michael

--Sig_/NCy0_TKkwwBoy=S2._9M=E5
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWI2R+AAoJEPUyvh2QjYsOfP4P/iJUG5fnkAc0Bj0Rw62VrrOM
nsxd/zyBFTrVxztJciz0dIR1T9nleGn8o82MNwaWz038SN7U4dofKLDZmi5lq2DS
7Fd+841H3CpAo1Raeq2oFqEcULmklsoZThT/wxljL5yIMRoztEIJmDGcBUiIZc2e
u01tKd3gQT6gw8rWK0ZS4vCE+ZlcOWQYRQ3PA9c5E+7N1EwY/EHkGhZfs07tu5aL
I/Un8lV4SGOi+pK8bAguYDKyilAkDVaTpSd1yxnpiSHiRV+P9nqV01wp1vAUoQKa
rrZ8Vt3Kttk9zcc/9dbEAGT47ZCjCyzZcOdrgOZw8dJz9pZcY2Ws9tgDxPwaMzq/
RUxwKJ/VOR03CwHsU7S4dEsDAgqre2/J27Lt23oNBdvo+g6qJZTfDVLwKOcpiGCj
gCKWjJPpV3SgAiz5EEZCTJqxl/s8kKgTo3K1be9MRrkSDHZpX49zNIQRjshSwyJQ
bNvWbqsVjmtbtT9Yic8nDhJ+OrlzBWpx3xXhN+7P8AWHjLhUyfcFs3SQVawEfeia
TcRSS/j4HUaiklIdqEiJZyg4vcDCAr82L2uLx6iJx0+K+6l3BrlbazTJwBFLLV4k
9DO2kWRHlwrdyzSW+Sunv2i3uKflqKHO7wASBA4PlBHC9e2jc4PbffwmgtWHG9Pw
T+zBUdIwCD24ZJtbxMR2
=YmE/
-----END PGP SIGNATURE-----

--Sig_/NCy0_TKkwwBoy=S2._9M=E5--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
