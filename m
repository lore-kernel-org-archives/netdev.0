From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [v10,
	7/7] mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
Date: Thu, 05 May 2016 13:10:31 +0200
Message-ID: <5159406.HOFrj7pRfW@wuerfel>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	<4448030.Zs8fVnr3nm@wuerfel>
	<HE1PR04MB0889B52134A43C0E7A452B7BF87C0@HE1PR04MB0889.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>, Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org>, Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Kumar G
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <HE1PR04MB0889B52134A43C0E7A452B7BF87C0-6LN7OEpIatX1kPMWxTxe+c9NdZoXdze2vxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 05 May 2016 09:41:32 Yangbo Lu wrote:
> > -----Original Message-----
> > From: Arnd Bergmann [mailto:arnd-r2nGTMty4D4@public.gmane.org]
> > Sent: Thursday, May 05, 2016 4:32 PM
> > To: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> > Cc: Yangbo Lu; linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; iommu-cunTk1MwBs/ROKNJybVBZg@public.gmane.org
> > foundation.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Mark Rutland;
> > ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; Russell King; Bhupesh Sharma; Joerg Roedel;
> > Santosh Shilimkar; Yang-Leo Li; Scott Wood; Rob Herring; Claudiu Manoil;
> > Kumar Gala; Xiaobo Xie; Qiang Zhao
> > Subject: Re: [v10, 7/7] mmc: sdhci-of-esdhc: fix host version for T4240-
> > R1.0-R2.0
> > 
> > On Thursday 05 May 2016 11:12:30 Yangbo Lu wrote:
> > >
> > > +       fsl_guts_init();
> > > +       svr = fsl_guts_get_svr();
> > > +       if (svr) {
> > > +               esdhc->soc_ver = SVR_SOC_VER(svr);
> > > +               esdhc->soc_rev = SVR_REV(svr);
> > > +       } else {
> > > +               dev_err(&pdev->dev, "Failed to get SVR value!\n");
> > > +       }
> > > +
> > >
> > 
> > 
> > Sorry for jumping in again after not participating in the discussion for
> > the past few versions.
> > 
> > What happened to my suggestion of making this a platform-independent
> > interface to avoid the link time dependency?
> > 
> > Specifically, why not add an exported function to drivers/base/soc.c that
> > uses glob_match() for comparing a string in the device driver to the ID
> > of the SoC that is set by whatever SoC identifying driver the platform
> > has?
> 
> [Lu Yangbo-B47093] I think this has been discussed in v6.
> You can find Scott's comments about this in below link.
> https://patchwork.kernel.org/patch/8544501/

Ah, thanks for bearing with me and digging this out again. Let me follow
up on Scott's older replies here then:

> >> IIRC, it is the same IP block as i.MX and Arnd's point is this won't
> >> even compile on !PPC. It is things like this that prevent sharing the
> >> driver.
> 
> The whole point of using the MMIO SVR instead of the PPC SPR is so that
> it will work on ARM...  The guts driver should build on any platform as
> long as OF is enabled, and if it doesn't find a node to bind to it will
> return 0 for SVR, and the eSDHC driver will continue (after printing an
> error that should be removed) without the ability to test for errata
> based on SVR.

It feels like a bad design to have to come up with a different
method for each SoC type here when they all do the same thing
and want to identify some variant of the chip to do device
specific quirks.

As far as I'm concerned, every driver in drivers/soc that needs to
export a symbol to be used by a device driver is an indication that
we don't have the right set of abstractions yet. There are cases
that are not worth abstracting because the functionality is rather
obscure and only a couple of drivers for one particular chip
ever need it.

Finding out the version of the SoC does not look like this case.

> > I think the first four patches take care of building for ARM,
> > but the problem remains if you want to enable COMPILE_TEST as
> > we need for certain automated checking.
> 
> What specific problem is there with COMPILE_TEST?

COMPILE_TEST is solvable here and the way it is implemented in this
case (selecting FSL_GUTS from the driver) indeed looks like it works
correctly, but it's still awkward that this means building the
SoC specific ID stuff into the vmlinux binary for any driver that
uses something like that for a particular SoC.

> >> Dealing with Si revs is a common problem. We should have a
> >> common solution. There is soc_device for this purpose.
> > 
> > Exactly. The last time this came up, I think we agreed to implement a
> > helper using glob_match() on the soc_device strings. Unfortunately
> > this hasn't happened then, but I'd still prefer that over yet another
> > vendor-specific way of dealing with the generic issue.
> 
> soc_device would require encoding the SVR as a string and then decoding
> the string, which is more complicated and error prone than having
> platform-specific code test a platform-specific number. 

You already need to encode it as a string to register the soc_device,
and the driver just needs to pass a glob string, so the only part that
is missing is the generic function that takes the string from the
driver and passes that to glob_match for the soc_device.

> And when would it get registered on arm64, which doesn't have
> platform code?

Whenever the soc driver is loaded, as is the case now. The match
function can return -EPROBE_DEFER if no SoC device is registered
yet.

	Arnd
