From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 08/21] ARM: dts: sun8i-h3: add dwmac-sun8i
 rgmii pins
Date: Fri, 17 Feb 2017 10:14:39 +0100
Message-ID: <20170217091439.GE22723@Red>
References: <20170216124859.14346-1-clabbe.montjoie@gmail.com>
 <20170216124859.14346-9-clabbe.montjoie@gmail.com>
 <20170216190632.hezcacn3hw5uhxcn@lukather>
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
Return-path: <linux-sunxi+bncBD7YLCN32UNBBBH6TLCQKGQEEK7Q7DY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170216190632.hezcacn3hw5uhxcn@lukather>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2017 at 08:06:32PM +0100, Maxime Ripard wrote:
> On Thu, Feb 16, 2017 at 01:48:46PM +0100, Corentin Labbe wrote:
> > This patch add pinctrl node for dwmac-sun8i on H3.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  arch/arm/boot/dts/sun8i-h3.dtsi | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> > 
> > diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8i-h3.dtsi
> > index 61d56d2..59ed40e 100644
> > --- a/arch/arm/boot/dts/sun8i-h3.dtsi
> > +++ b/arch/arm/boot/dts/sun8i-h3.dtsi
> > @@ -349,6 +349,17 @@
> >  				function = "i2c2";
> >  			};
> >  
> > +			emac_rgmii_pins: emac0@0 {
> > +				allwinner,pins = "PD0", "PD1", "PD2", "PD3",
> > +						"PD4", "PD5", "PD7",
> > +						"PD8", "PD9", "PD10",
> > +						"PD12", "PD13", "PD15",
> > +						"PD16", "PD17";
> > +				allwinner,function = "emac";
> 
> Please use the generic pin config properties (ie. pins and functions).
> 
> > +				allwinner,drive = <SUN4I_PINCTRL_40_MA>;
> 
> Why do you need to use 40mA?
> 
> > +				allwinner,pull = <SUN4I_PINCTRL_NO_PULL>;
> 
> This is the default now.
> 

Will fix that in all DT

Thanks
Corentin Labbe
