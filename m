From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] Added SIOCSMIIREG (mii write) support to intel igb
 driver
Date: Mon, 26 Jun 2017 14:11:52 -0700
Message-ID: <1498511512.3237.7.camel@intel.com>
References: <20170622132356.2567-1-michael.moese@men.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-hYbq/CUZQ0w9R0bKQ35b"
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Andreas Werner <andreas.werner@men.de>
To: Michael Moese <michael.moese@men.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170622132356.2567-1-michael.moese@men.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-hYbq/CUZQ0w9R0bKQ35b
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-06-22 at 15:23 +0200, Michael Moese wrote:
> From: Andreas Werner <andreas.werner@men.de>
>=20
> Signed-off-by: Andreas Werner <andreas.werner@men.de>
> ---
> =C2=A0drivers/net/ethernet/intel/igb/igb_main.c | 4 ++++
> =C2=A01 file changed, 4 insertions(+)

NACK

Why?  Your lack of patch description does not provide a reasoning on why we
need this change.  I need a patch description that provides justification
on why we need this change, before I add this to my queue for testing and
acceptance upstream.

Please resubmit with the requested information/change.

>=20
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
> b/drivers/net/ethernet/intel/igb/igb_main.c
> index 1cf74aa4ebd9..87e496eeefb1 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -7716,6 +7716,10 @@ static int igb_mii_ioctl(struct net_device
> *netdev, struct ifreq *ifr, int cmd)
> =C2=A0			return -EIO;
> =C2=A0		break;
> =C2=A0	case SIOCSMIIREG:
> +		if (igb_write_phy_reg(&adapter->hw, data->reg_num &
> 0x1F,
> +				=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0data->val_in))
> +			return -EIO;
> +		break;
> =C2=A0	default:
> =C2=A0		return -EOPNOTSUPP;
> =C2=A0	}

--=-hYbq/CUZQ0w9R0bKQ35b
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZUXiYAAoJEOVv75VaS+3OZngQAJ6xpQpoZfmbTWj0sLsKAuH+
tJP3zlK5Du5wDnn4Izy4tCdlnXKwwL9ACVMQaFwTiTQjyn+I9a1h0B52dnKiNi2B
obGK1r/oBL+fcHpE4Yrlpka6uDnsnY1fznd/rxJNUNyJrXhJTDBs3yKL56rmw0hY
XMiiQNpuJMrDgy6M9Vp7D9necaQOWMCMSt4eZuqHz87hpqWdiJ+AigykgfEUFOL2
G+TJD83vqfuOj50leDSxn4RB7I+5HBftEP/khFzcOInJ5/pSm90SkSDDAFIIffw/
zixjf37A0t6lAqMwJOQN4f3YtHznuNKfv8uid8oUHup976ff6DU28yLIQ6nFVj+R
aKGnVlNG4F75o1e9+vHHRULC1Ogc0+v159nY3ufzzJbCOylJwaytKFpSJI6KdGXq
o+svHQ84CsvOBsOGpgI+nhShXxWNoFc04EfDJCdRSqQgINBI063e+FDxSG8yB60c
RgmPf5+1Vm229bzTwvs3VlzQ205LDknHLa1366NNyIJVO4Q5F89O504SDB1uHVNj
ZglKdB+cF9Fj39ljTnfFr+qveshzFKTwpNa7FIwRe1UcKUluNn9PoflYamiOEZpG
LrDUvlXmdR5Tp6Cj+R0dc2k8AsRO5K6Ts1zAmUjDz+j43K8rcCVucnYOaIaBCQ8t
UqqR2yQWoknVXeWtPSX1
=m5+2
-----END PGP SIGNATURE-----

--=-hYbq/CUZQ0w9R0bKQ35b--
