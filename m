From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 13/18] arm64: allwinner: sun50i-a64: add
 dwmac-sun8i Ethernet driver
Date: Mon, 24 Apr 2017 14:24:11 +0200
Message-ID: <20170424122411.GA9349@Red>
References: <20170412111400.2296-1-clabbe.montjoie@gmail.com>
 <20170412111400.2296-14-clabbe.montjoie@gmail.com>
 <20170412124153.q6zvdvqkroizaxgb@lukather>
Reply-To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBD7YLCN32UNBB4G467DQKGQEJXDRXGY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170412124153.q6zvdvqkroizaxgb@lukather>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2017 at 02:41:53PM +0200, Maxime Ripard wrote:
> On Wed, Apr 12, 2017 at 01:13:55PM +0200, Corentin Labbe wrote:
> > The dwmac-sun8i is an Ethernet MAC that supports 10/100/1000 Mbit
> > connections. It is very similar to the device found in the Allwinner
> > H3, but lacks the internal 100 Mbit PHY and its associated control
> > bits.
> > This adds the necessary bits to the Allwinner A64 SoC .dtsi, but keeps
> > it disabled at this level.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi | 37 +++++++++++++++++++++++++++
> >  1 file changed, 37 insertions(+)
> > 
> > diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
> > index 0b0f4ab..2569827 100644
> > --- a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
> > +++ b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
> > @@ -287,6 +287,23 @@
> >  				bias-pull-up;
> >  			};
> >  
> > +			rmii_pins: rmii_pins {
> > +				pins = "PD10", "PD11", "PD13", "PD14",
> > +						"PD17", "PD18", "PD19", "PD20",
> > +						"PD22", "PD23";
> 
> Please align the wrapped lines on the first pin.
> 

OK

> > +				function = "emac";
> > +				drive-strength = <40>;
> 
> Do you actually need that for all the boards, or only a few of them?

I have tried to use lower value without success on some boards. (opipc/pine64 in my memory)

Regards
Corentin Labbe
