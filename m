From: LABBE Corentin <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 4/9] ARM: dts: sun8i-h3: Add dt node for the syscon
 control module
Date: Tue, 13 Sep 2016 15:38:14 +0200
Message-ID: <20160913133814.GD31990@Red>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-5-git-send-email-clabbe.montjoie@gmail.com>
 <20160912072812.GB9449@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160912072812.GB9449@lukather>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 09:28:12AM +0200, Maxime Ripard wrote:
> On Fri, Sep 09, 2016 at 02:45:12PM +0200, Corentin Labbe wrote:
> > This patch add the dt node for the syscon register present on the
> > Allwinner H3.
> > 
> > Only two register are present in this syscon and the only one useful is
> > the one dedicated to EMAC clock.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  arch/arm/boot/dts/sun8i-h3.dtsi | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8i-h3.dtsi
> > index fdf9fdb..a39da6f 100644
> > --- a/arch/arm/boot/dts/sun8i-h3.dtsi
> > +++ b/arch/arm/boot/dts/sun8i-h3.dtsi
> > @@ -140,6 +140,11 @@
> >  		#size-cells = <1>;
> >  		ranges;
> >  
> > +		syscon: syscon@01c00000 {
> > +			compatible = "syscon";
> 
> Having our compatible would be nice here. syscon doesn't mean anything
> by itself.
> 

Since no driver handle it, I follow what I saw in other DT.
At your choice, I can add a sun8i-syscon, but it will be unused.

> > +			reg = <0x01c00000 0x34>;
> 
> And the size of our system controller is 0x1000
> 

I put the real size used, but I can put what datasheet said.

Regards

Corentin Labbe
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
