From: "Y.B. Lu" <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [v12, 0/8] Fix eSDHC host version register bug
Date: Wed, 19 Oct 2016 02:40:53 +0000
Message-ID: <AM5PR0401MB2529907DE940AC310FC8C0B2F8D20@AM5PR0401MB2529.eurprd04.prod.outlook.com>
References: <1474441040-11946-1-git-send-email-yangbo.lu@nxp.com>
	<CAPDyKFoit0sTPpfi2=AHcdZsDwOJxbBX68O-1jBFL=5JN0m6_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, "X.B. Xie" <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>,
	"M.H. Lian" <minghuan.lian-3arQi8VN3Tc@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-clk <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, Bhupesh
	Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-mmc <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Kumar Gal
To: Ulf Hansson <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, "Arnd
	Bergmann" <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAPDyKFoit0sTPpfi2=AHcdZsDwOJxbBX68O-1jBFL=5JN0m6_w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
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

> -----Original Message-----
> From: Ulf Hansson [mailto:ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org]
> Sent: Tuesday, October 18, 2016 6:48 PM
> To: Y.B. Lu
> Cc: linux-mmc; Scott Wood; Arnd Bergmann; linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org;
> devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-clk; linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Mark Rutland;
> Rob Herring; Russell King; Jochen Friedrich; Joerg Roedel; Claudiu Manoil;
> Bhupesh Sharma; Qiang Zhao; Kumar Gala; Santosh Shilimkar; Leo Li; X.B.
> Xie; M.H. Lian
> Subject: Re: [v12, 0/8] Fix eSDHC host version register bug
> 
> On 21 September 2016 at 08:57, Yangbo Lu <yangbo.lu-3arQi8VN3Tc@public.gmane.org> wrote:
> > This patchset is used to fix a host version register bug in the
> > T4240-R1.0-R2.0 eSDHC controller. To match the SoC version and
> > revision, 10 previous version patchsets had tried many methods but all
> of them were rejected by reviewers.
> > Such as
> >         - dts compatible method
> >         - syscon method
> >         - ifdef PPC method
> >         - GUTS driver getting SVR method Anrd suggested a
> > soc_device_match method in v10, and this is the only available method
> > left now. This v11 patchset introduces the soc_device_match interface
> > in soc driver.
> >
> > The first six patches of Yangbo are to add the GUTS driver. This is
> > used to register a soc device which contain soc version and revision
> information.
> > The other two patches introduce the soc_device_match method in soc
> > driver and apply it on esdhc driver to fix this bug.
> >
> > Arnd Bergmann (1):
> >   base: soc: introduce soc_device_match() interface
> >
> > Yangbo Lu (7):
> >   dt: bindings: update Freescale DCFG compatible
> >   ARM64: dts: ls2080a: add device configuration node
> >   dt: bindings: move guts devicetree doc out of powerpc directory
> >   powerpc/fsl: move mpc85xx.h to include/linux/fsl
> >   soc: fsl: add GUTS driver for QorIQ platforms
> >   MAINTAINERS: add entry for Freescale SoC drivers
> >   mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
> >
> >  Documentation/devicetree/bindings/arm/fsl.txt      |   6 +-
> >  .../bindings/{powerpc => soc}/fsl/guts.txt         |   3 +
> >  MAINTAINERS                                        |  11 +-
> >  arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi     |   6 +
> >  arch/powerpc/kernel/cpu_setup_fsl_booke.S          |   2 +-
> >  arch/powerpc/sysdev/fsl_pci.c                      |   2 +-
> >  drivers/base/Kconfig                               |   1 +
> >  drivers/base/soc.c                                 |  66 ++++++
> >  drivers/clk/clk-qoriq.c                            |   3 +-
> >  drivers/i2c/busses/i2c-mpc.c                       |   2 +-
> >  drivers/iommu/fsl_pamu.c                           |   3 +-
> >  drivers/mmc/host/Kconfig                           |   1 +
> >  drivers/mmc/host/sdhci-of-esdhc.c                  |  20 ++
> >  drivers/net/ethernet/freescale/gianfar.c           |   2 +-
> >  drivers/soc/Kconfig                                |   2 +-
> >  drivers/soc/fsl/Kconfig                            |  19 ++
> >  drivers/soc/fsl/Makefile                           |   1 +
> >  drivers/soc/fsl/guts.c                             | 257
> +++++++++++++++++++++
> >  include/linux/fsl/guts.h                           | 125 ++++++----
> >  .../asm/mpc85xx.h => include/linux/fsl/svr.h       |   4 +-
> >  include/linux/sys_soc.h                            |   3 +
> >  21 files changed, 478 insertions(+), 61 deletions(-)  rename
> > Documentation/devicetree/bindings/{powerpc => soc}/fsl/guts.txt (91%)
> > create mode 100644 drivers/soc/fsl/Kconfig  create mode 100644
> > drivers/soc/fsl/guts.c  rename arch/powerpc/include/asm/mpc85xx.h =>
> > include/linux/fsl/svr.h (97%)
> >
> > --
> > 2.1.0.27.g96db324
> >
> 
> This looks good to me! I am not sure which tree you want this to be
> picked up through, but unless no other volunteers I can take it through
> my mmc tree.
> 
> Although, before considering to apply, I need an ack from Scott/Arnd for
> the guts driver in patch 5/8 and I need an ack from Greg for patch 7/8,
> where the soc_device_match() interface is added (seems like you didn't
> add him on cc/to).
> 

[Lu Yangbo-B47093] Thanks a lot for your clarifying, Uffe.
This patchset was based on mmc tree, and needed your picking up.
But I think it needs to be rebased now since I saw qbman driver was in drivers/soc/fsl/ now.
I will do that after collecting others' ACKs or comments.

Hi Scott and Arnd,
Could I get your ACTs if there're no other changes needed?
Thanks a lot.

> Kind regards
> Uffe
