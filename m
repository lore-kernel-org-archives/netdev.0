From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v3 04/20] ARM: sun8i: dt: Add DT bindings documentation
 for Allwinner syscon
Date: Fri, 7 Apr 2017 14:50:44 +0200
Message-ID: <20170407125044.GB15546@Red>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
 <20170403091444.29876-5-clabbe.montjoie@gmail.com>
 <20170403111954.tolvlw7klswaxkl4@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170403111954.tolvlw7klswaxkl4@lukather>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 03, 2017 at 01:19:54PM +0200, Maxime Ripard wrote:
> On Mon, Apr 03, 2017 at 11:14:28AM +0200, Corentin Labbe wrote:
> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  .../devicetree/bindings/misc/allwinner,syscon.txt     | 19 +++++++++++++++++++
> >  1 file changed, 19 insertions(+)
> >  create mode 100644 Documentation/devicetree/bindings/misc/allwinner,syscon.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/misc/allwinner,syscon.txt b/Documentation/devicetree/bindings/misc/allwinner,syscon.txt
> > new file mode 100644
> > index 0000000..9f5f1f5
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/misc/allwinner,syscon.txt
> > @@ -0,0 +1,19 @@
> > +* Allwinner sun8i system controller
> > +
> > +This file describes the bindings for the system controller present in
> > +Allwinner SoC H3, A83T and A64.
> > +The principal function of this syscon is to control EMAC PHY choice and
> > +config.
> > +
> > +Required properties for the system controller:
> > +- reg: address and length of the register for the device.
> > +- compatible: should be "syscon" and one of the following string:
> > +		"allwinner,sun8i-h3-system-controller"
> > +		"allwinner,sun8i-a64-system-controller"
> > +		"allwinner,sun8i-a83t-system-controller"
> > +
> > +Example:
> > +syscon: syscon@01c00000 {
> > +	compatible = "syscon", "allwinner,sun8i-h3-system-controller";
> 
> The syntax is the more specific first, so your compatibles should be
> the other way around.
> 

Changed it everywhere, and forgot to do it here
I will change it

Thanks
Regards
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
