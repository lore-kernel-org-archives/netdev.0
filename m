From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [v10, 3/7] soc: fsl: add GUTS driver for QorIQ platforms
Date: Fri, 15 Jul 2016 18:39:33 -0400
Message-ID: <20160715223932.GC10758@windriver.com>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
 <1462417950-46796-4-git-send-email-yangbo.lu@nxp.com>
 <CAP=VYLqsV_M=8CM47k4kzdULCp_y0yP9t8Sq9=jFp6W593QJgw@mail.gmail.com>
 <1468609977.25630.5.camel@buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yangbo Lu <yangbo.lu@nxp.com>, <linux-mmc@vger.kernel.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	<devicetree@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, <linux-clk@vger.kernel.org>,
	<linux-i2c@vger.kernel.org>, <iommu@lists.linux-foundation.org>,
	netdev <netdev@vger.kernel.org>, <ulf.hansson@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Kumar Gala <galak@codeaurora.org>,
	Santosh Shilimkar <ssantosh@kernel.org>, <leoyang.li@nxp.com>,
	<xiaobo.xie@nxp.com>
To: Scott Wood <oss@buserror.net>
Return-path: <linux-clk-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1468609977.25630.5.camel@buserror.net>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Re: [v10, 3/7] soc: fsl: add GUTS driver for QorIQ platforms] On 15/07=
/2016 (Fri 14:12) Scott Wood wrote:

> On Fri, 2016-07-15 at 12:43 -0400, Paul Gortmaker wrote:
> > > +source "drivers/soc/fsl/qe/Kconfig"

[...]

> > > +
> > > +config FSL_GUTS
> > > +=A0=A0=A0=A0=A0=A0=A0bool
> > > diff --git a/drivers/soc/fsl/Makefile b/drivers/soc/fsl/Makefile
> > > index 203307f..02afb7f 100644
> > > --- a/drivers/soc/fsl/Makefile
> > > +++ b/drivers/soc/fsl/Makefile
> > > @@ -4,3 +4,4 @@
> > >=20
> > > =A0obj-$(CONFIG_QUICC_ENGINE)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0+=3D qe/
> > > =A0obj-$(CONFIG_CPM)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0+=3D qe/
> > > +obj-$(CONFIG_FSL_GUTS)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0+=3D guts.o
> > > diff --git a/drivers/soc/fsl/guts.c b/drivers/soc/fsl/guts.c
> > > new file mode 100644
> > > index 0000000..fa155e6
> > > --- /dev/null
> > > +++ b/drivers/soc/fsl/guts.c
> > > @@ -0,0 +1,119 @@
> > > +/*
> > > + * Freescale QorIQ Platforms GUTS Driver
> > > + *
> > > + * Copyright (C) 2016 Freescale Semiconductor, Inc.
> > > + *
> > > + * This program is free software; you can redistribute it and/or=
 modify
> > > + * it under the terms of the GNU General Public License as publi=
shed by
> > > + * the Free Software Foundation; either version 2 of the License=
, or
> > > + * (at your option) any later version.
> > > + */
> > > +
> > > +#include <linux/io.h>
> > > +#include <linux/module.h>
> > Seems there was lots of discussion on this.=A0=A0If it does end up =
being
> > resent, it would be nice to get the module.h and other modular stuf=
f
> > gone since it is a bool Kconfig.
>=20
> I plan to resend just the GUTS driver portion and send it through the=
 PPC
> tree.
>=20
> I don't see any modular stuff in there besides the linux/module.h inc=
lude.

Great.  Normally I'm seeing the MODULE_DEVICE_TABLE and MODULE_AUTHOR
and MODULE_LICENSE etc, so it has (unfortunately) become a knee jerk
reaction to assume the latter follows a module.h presence...  thanks fo=
r
removing the extraneous include.

Paul.
--

>=20
> -Scott
>=20
>=20
