From: "Y.B. Lu" <yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [v12, 0/8] Fix eSDHC host version register bug
Date: Mon, 26 Sep 2016 03:14:32 +0000
Message-ID: <HE1PR04MB08893C8EE38DB311648C1109F8CD0@HE1PR04MB0889.eurprd04.prod.outlook.com>
References: <1474441040-11946-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
        Jochen Friedrich <jochen-NIgtFMG+Po8@public.gmane.org>,
        Joerg Roedel <joro-zLv9SwRftAIdnm+yROfE0A@public.gmane.org>,
        Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
        Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
To: "linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474441040-11946-1-git-send-email-yangbo.lu-3arQi8VN3Tc@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Any comments about this version patchset ?

:)


> -----Original Message-----
> From: Yangbo Lu [mailto:yangbo.lu-3arQi8VN3Tc@public.gmane.org]
> Sent: Wednesday, September 21, 2016 2:57 PM
> To: linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; Scott Wood; Arnd
> Bergmann
> Cc: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-arm-
> kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; iommu-cunTk1MwBs/ROKNJybVBZg@public.gmane.org
> foundation.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Mark Rutland; Rob Herring;
> Russell King; Jochen Friedrich; Joerg Roedel; Claudiu Manoil; Bhupesh
> Sharma; Qiang Zhao; Kumar Gala; Santosh Shilimkar; Leo Li; X.B. Xie; M.H.
> Lian; Y.B. Lu
> Subject: [v12, 0/8] Fix eSDHC host version register bug
>=20
> This patchset is used to fix a host version register bug in the T4240-
> R1.0-R2.0 eSDHC controller. To match the SoC version and revision, 10
> previous version patchsets had tried many methods but all of them were
> rejected by reviewers.
> Such as
> 	- dts compatible method
> 	- syscon method
> 	- ifdef PPC method
> 	- GUTS driver getting SVR method
> Anrd suggested a soc_device_match method in v10, and this is the only
> available method left now. This v11 patchset introduces the
> soc_device_match interface in soc driver.
>=20
> The first six patches of Yangbo are to add the GUTS driver. This is used
> to register a soc device which contain soc version and revision
> information.
> The other two patches introduce the soc_device_match method in soc driver
> and apply it on esdhc driver to fix this bug.
>=20
> Arnd Bergmann (1):
>   base: soc: introduce soc_device_match() interface
>=20
> Yangbo Lu (7):
>   dt: bindings: update Freescale DCFG compatible
>   ARM64: dts: ls2080a: add device configuration node
>   dt: bindings: move guts devicetree doc out of powerpc directory
>   powerpc/fsl: move mpc85xx.h to include/linux/fsl
>   soc: fsl: add GUTS driver for QorIQ platforms
>   MAINTAINERS: add entry for Freescale SoC drivers
>   mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
>=20
>  Documentation/devicetree/bindings/arm/fsl.txt      |   6 +-
>  .../bindings/{powerpc =3D> soc}/fsl/guts.txt         |   3 +
>  MAINTAINERS                                        |  11 +-
>  arch/arm64/boot/dts/freescale/fsl-ls2080a.dtsi     |   6 +
>  arch/powerpc/kernel/cpu_setup_fsl_booke.S          |   2 +-
>  arch/powerpc/sysdev/fsl_pci.c                      |   2 +-
>  drivers/base/Kconfig                               |   1 +
>  drivers/base/soc.c                                 |  66 ++++++
>  drivers/clk/clk-qoriq.c                            |   3 +-
>  drivers/i2c/busses/i2c-mpc.c                       |   2 +-
>  drivers/iommu/fsl_pamu.c                           |   3 +-
>  drivers/mmc/host/Kconfig                           |   1 +
>  drivers/mmc/host/sdhci-of-esdhc.c                  |  20 ++
>  drivers/net/ethernet/freescale/gianfar.c           |   2 +-
>  drivers/soc/Kconfig                                |   2 +-
>  drivers/soc/fsl/Kconfig                            |  19 ++
>  drivers/soc/fsl/Makefile                           |   1 +
>  drivers/soc/fsl/guts.c                             | 257
> +++++++++++++++++++++
>  include/linux/fsl/guts.h                           | 125 ++++++----
>  .../asm/mpc85xx.h =3D> include/linux/fsl/svr.h       |   4 +-
>  include/linux/sys_soc.h                            |   3 +
>  21 files changed, 478 insertions(+), 61 deletions(-)  rename
> Documentation/devicetree/bindings/{powerpc =3D> soc}/fsl/guts.txt (91%)
> create mode 100644 drivers/soc/fsl/Kconfig  create mode 100644
> drivers/soc/fsl/guts.c  rename arch/powerpc/include/asm/mpc85xx.h =3D>
> include/linux/fsl/svr.h (97%)
>=20
> --
> 2.1.0.27.g96db324

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
