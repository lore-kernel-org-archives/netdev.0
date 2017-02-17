From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 20/21] ARM: sunxi: Enable dwmac-sun8i driver
 on sunxi_defconfig
Date: Fri, 17 Feb 2017 09:55:19 +0100
Message-ID: <20170217085519.GD22723@Red>
References: <20170216124859.14346-1-clabbe.montjoie@gmail.com>
 <20170216124859.14346-21-clabbe.montjoie@gmail.com>
 <20170216190827.jaky5xyzqtuzhy76@lukather>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	wens-jdAy2FN1RRM@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
	will.deacon-5wv7dgnIgG8@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBD7YLCN32UNBB7HUTLCQKGQESWCXSAY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170216190827.jaky5xyzqtuzhy76@lukather>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2017 at 08:08:27PM +0100, Maxime Ripard wrote:
> Hi,
> 
> On Thu, Feb 16, 2017 at 01:48:58PM +0100, Corentin Labbe wrote:
> > From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > 
> > Enable the dwmac-sun8i driver in the sunxi default configuration
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  arch/arm/configs/sunxi_defconfig | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/arch/arm/configs/sunxi_defconfig b/arch/arm/configs/sunxi_defconfig
> > index da92c25..33bde86 100644
> > --- a/arch/arm/configs/sunxi_defconfig
> > +++ b/arch/arm/configs/sunxi_defconfig
> > @@ -40,6 +40,7 @@ CONFIG_ATA=y
> >  CONFIG_AHCI_SUNXI=y
> >  CONFIG_NETDEVICES=y
> >  CONFIG_SUN4I_EMAC=y
> > +CONFIG_DWMAC_SUN8I=m
> 
> I think I'd prefer to have it compiled statically, just like the other
> net drivers, and drivers in general.
> 
> Thanks!
> Maxime
> 

In previous sun8i-emac, someone request that CONFIG must be set as module because kernel went too big.
But I do not care to set it statically.

Regards
Corentin Labbe
