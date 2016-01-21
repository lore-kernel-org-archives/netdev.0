From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH RESEND v2] ixgbe: on recv increment rx.ring->stats.yields
Date: Wed, 20 Jan 2016 19:32:19 -0800
Message-ID: <1453347139.3312.2.camel@intel.com>
References: <1453277324-6180-1-git-send-email-ptikhomirov@virtuozzo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-L+Ohn9CMHc3aQSEUnx+1"
Cc: Andrew Vagin <avagin@parallels.com>,
	Konstantin Khorenko <khorenko@virtuozzo.com>, devel@openvz.org
To: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15812 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbcAUDc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2016 22:32:28 -0500
In-Reply-To: <1453277324-6180-1-git-send-email-ptikhomirov@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-L+Ohn9CMHc3aQSEUnx+1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-01-20 at 11:08 +0300, Pavel Tikhomirov wrote:
> It seem to be non intentionaly changed to tx in
> commit adc810900a70 ("ixgbe: Refactor busy poll socket code to
> address
> multiple issues")
>=20
> Lock is taken from ixgbe_low_latency_recv, and there under this
> lock we use ixgbe_clean_rx_irq so it looks wrong for me to increment
> tx counter.
>=20
> Yield stats can be shown through ethtool:
> ethtool -S enp129s0 | grep yield
>=20
> v2: follow commit citing style
>=20
> Signed-off-by: Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe.h | 2 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)

Why are you re-sending this patch? =C2=A0I already have it queued up for
testing in my tree. =C2=A0This just causes problems and extra work for me.
--=-L+Ohn9CMHc3aQSEUnx+1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWoFFDAAoJEOVv75VaS+3ONHUP/2kI/w5XYhAnrg3DmQryx6bq
QEM7gkyeT8PePlCUvFjCGpUHwWjbB0UGpZ4pSJub8kk29o4dugnjHY3xmiu5FBl5
hlsy+P8G3w1SjqX8vokG2CNH1+WixyaEB5LTi2urajyg3rJZwQoMgpapv2cf5d7U
q12QbFNL9c9rprHui9Zc77PVJPeb9u9JgALSG/IrAf3ap0TuiYuYWedBQXwQsZpb
HwqEfeEr58NjncX0qlJZt1WFlSL3MGNygdz/DThGGc2czDaJlcCrMhnIzFLu12UL
65PmHTYk/bv/09maANhUboCSlpREQjX8G72r8EqXsa+PESdO3P188AmFb9aeDna7
YrPZ85CN9Q9yLkjdbmoPVg+o1IjyMsfsrEN9jjIn+wPm8+ysH0c2VHVLO3CTudff
eanVYf55xWRfHPBcVU5HHzcSYc2lqhUEMhFqTY8P38Vd1sRtXDTdSZfBU1izpIgV
U06kwpOHRSZPv5fF/vGLTzGMJDKy/HQ3uMltu8av/3yt3aPVS4XAUl3sbH5GzIX1
o84tNV6aGqvl8Zcz7AFNi/XxhRMcOxGvj9eoWoJhFTIgcT4jIf/UJvLSJ/tVqfla
PywJ4a6TE/5jXYwCn+DpsTQrPRIOkBguvwmKSwLPimhNUmxUO8Dxt4BKjoyG3xv9
lOplm93KoTp0nTLzmReu
=lN+h
-----END PGP SIGNATURE-----

--=-L+Ohn9CMHc3aQSEUnx+1--
