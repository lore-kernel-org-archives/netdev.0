From: Ohad Oz <ohado@mellanox.com>
Subject: RE: [patch v1 1/2] Allow Mellanox network vendor to be configured if
 only I2C bus is configured
Date: Sun, 13 Aug 2017 15:26:56 +0000
Message-ID: <VI1PR05MB1262B06790B2738CE1C0F889C88F0@VI1PR05MB1262.eurprd05.prod.outlook.com>
References: <1502385112-103765-1-git-send-email-ohado@mellanox.com>
 <20170812143715.GN24282@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jiri@resnulli.us" <jiri@resnulli.us>,
        "Saeed Mahameed" <saeedm@mellanox.com>,
        Vadim Pasternak <vadimp@mellanox.com>,
        system-sw-low-level <system-sw-low-level@mellanox.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0045.outbound.protection.outlook.com ([104.47.0.45]:3264
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750982AbdHMP1A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Aug 2017 11:27:00 -0400
In-Reply-To: <20170812143715.GN24282@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Leon Romanovsky [mailto:leon@kernel.org]
> Sent: Saturday, August 12, 2017 5:37 PM
> To: Ohad Oz <ohado@mellanox.com>
> Cc: davem@davemloft.net; netdev@vger.kernel.org; jiri@resnulli.us; Saeed
> Mahameed <saeedm@mellanox.com>; Vadim Pasternak
> <vadimp@mellanox.com>; system-sw-low-level <system-sw-low-
> level@mellanox.com>
> Subject: Re: [patch v1 1/2] Allow Mellanox network vendor to be configure=
d
> if only I2C bus is configured
>=20
> On Thu, Aug 10, 2017 at 05:11:51PM +0000, Ohad Oz wrote:
> > Patch allows Mellanox devices on system with no PCI, but with I2C only.
> >
>=20
> Did you test mlx5 device on such system? Did it work for you?

Yes, I did. With PCI config set to disable mlx5 drivers are not built.=20
Only the following:=20
/build/drivers/net/Ethernet/mellanox/mlxsw/mlxsw_core.ko
/build/drivers/net/Ethernet/mellanox /mlxsw/mlxsw_i2c.ko
/build/drivers/net/Ethernet/mellanox /mlxsw/mlxsw_minimal.ko

While with both options on all drivers are built inc mlx5.


> What is the changelog between v0 and v1 of these patches?

No changelog, I've started with v1.

>=20
> > Signed-off-by: Ohad Oz <ohado@mellanox.com>
> > ---
> >  drivers/net/ethernet/mellanox/Kconfig | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/Kconfig
> b/drivers/net/ethernet/mellanox/Kconfig
> > index 84a2007..0949741 100644
> > --- a/drivers/net/ethernet/mellanox/Kconfig
> > +++ b/drivers/net/ethernet/mellanox/Kconfig
> > @@ -5,7 +5,7 @@
> >  config NET_VENDOR_MELLANOX
> >  	bool "Mellanox devices"
> >  	default y
> > -	depends on PCI
> > +	depends on PCI || I2C
> >  	---help---
> >  	  If you have a network (Ethernet) card belonging to this class, say =
Y.
> >
> > --
> > 2.8.0
> >
