From: Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v4 7/9] net: pxa168_eth: allow Berlin SoCs to use the
 pxa168_eth driver
Date: Tue, 23 Sep 2014 15:50:07 +0200
Message-ID: <20140923135007.GB18924@kwain>
References: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com>
 <1411474536-22626-8-git-send-email-antoine.tenart@free-electrons.com>
 <4458671.9hKSvmlZNz@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, zmxu-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4458671.9hKSvmlZNz@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnd,

On Tue, Sep 23, 2014 at 02:40:01PM +0200, Arnd Bergmann wrote:
> On Tuesday 23 September 2014 14:15:34 Antoine Tenart wrote:
> > diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/eth=
ernet/marvell/Kconfig
> > index 1b4fc7c639e6..48b9466d1781 100644
> > --- a/drivers/net/ethernet/marvell/Kconfig
> > +++ b/drivers/net/ethernet/marvell/Kconfig
> > @@ -64,7 +64,7 @@ config MVPP2
> > =20
> >  config PXA168_ETH
> >         tristate "Marvell pxa168 ethernet support"
> > -       depends on CPU_PXA168
> > +       depends on CPU_PXA168 || ARCH_BERLIN
> >         select PHYLIB
> >         ---help---
> >           This driver supports the pxa168 Ethernet ports.
> >=20
>=20
> Myabe you can also add '|| COMPILE_TEST' here, to allow building it

We can add this.

> on other architectures. Check if you need 'depends on OF' though.

I don't think that's needed, the driver still supports non-dt cases.
I'll check.

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
