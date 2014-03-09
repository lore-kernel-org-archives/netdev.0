From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 5/6] Drivers: net: hyperv: Enable send side checksum
 offload
Date: Sun, 09 Mar 2014 18:53:35 +0000
Message-ID: <1394391215.15968.10.camel@deadeye.wl.decadent.org.uk>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-5-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6074936401748620906=="
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org,
 davem@davemloft.net
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1394104390-23477-5-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org


--===============6074936401748620906==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7lnaNoDM4cc8PfvgbnVr"


--=-7lnaNoDM4cc8PfvgbnVr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-06 at 03:13 -0800, K. Y. Srinivasan wrote:
[...]
> @@ -593,8 +658,9 @@ static int netvsc_probe(struct hv_device *dev,
>  	net->netdev_ops =3D &device_ops;
> =20
>  	/* TODO: Add GSO and Checksum offload */
> -	net->hw_features =3D NETIF_F_RXCSUM | NETIF_F_SG;
> -	net->features =3D NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_RXCSUM=
;
> +	net->hw_features =3D NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_IP_CSUM;
> +	net->features =3D NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_SG | NETIF_F_RXCSUM=
 |
> +			NETIF_F_IP_CSUM;

Missing NETIF_F_IPV6_CSUM?

Ben.

>  	SET_ETHTOOL_OPS(net, &ethtool_ops);
>  	SET_NETDEV_DEV(net, &dev->device);

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-7lnaNoDM4cc8PfvgbnVr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxy4r+e/yOyVhhEJAQpsEA/7BzDm+K0Zk5/raSku9GyowwdFvpIJxcqp
mYPQq2cMZ1hv6foGW6J62a1rGAI+LPN20wYr3GHGZehCcZSpI0Ao4jV+oT+Znf2z
NgaSdgNR4IS6nMCf4RE4mGZ48RZ3AYjc/QF88TymqbzGXUc13u+ZnTwgFFZXA3kA
slw8vGK+JzydoF2LULr3qVKFlwNArlHtq36wJo3ZVJZuCU0Cev/xX82YYrsVn72r
8bQy966X9IiMpot1ORohDPeIdJtrblL2jauNxRfv/IpaFjqFQmsSLiLV+/fk+6zw
UH+B3JeqvEBjEDoMQwrexrZ/E5AAGwBaF1nZcIR9wockhQfWFZ/Xu59emKH0+BBc
Dnch5hVzHECx29si4r9UxoB4O7TPuCB1g8a0neExJVm60Bwtl0+zBiZTHBrXizC1
uuBVT3vir4RXYMh8tsQrQztEFZiKpzVPY8gE6iM90wLe5fk1RmZi/ABRcsxxtB9y
kDDtrjdKT2SVMW8bjMaWgpzRINGpV1rpEitp4HXCZbrH6ZFizfu76UZVFrWyPdba
oA/RueVW7I1yA40rjOVNzictQrdlP3kegQtg4/bbc7fTP9CfM6LxSktpKXYUG42/
FVhMrgUczb6A9VEaxoPvzVNh2l1wqzY4B0quZqioARuN+XGK8kQSA+neIC8prJxv
USFpVJyEzJ8=
=qdFc
-----END PGP SIGNATURE-----

--=-7lnaNoDM4cc8PfvgbnVr--

--===============6074936401748620906==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============6074936401748620906==--
