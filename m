From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: RE: [PATCH 1/6] bus: Add shared MDIO bus framework
Date: Mon, 25 Apr 2016 09:39:38 +0530
Message-ID: <5876c521a46dbb4bd1b0c22bc64ec1a5@mail.gmail.com>
References: <1461230323-27891-1-git-send-email-pramod.kumar@broadcom.com>
	<1461230323-27891-2-git-send-email-pramod.kumar@broadcom.com> <20160424.141806.786009616301278103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: robh+dt@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com,
	yamada.masahiro@socionext.com, wens@csie.org,
	bcm-kernel-feedback-list@broadcom.com, pawel.moll@arm.com,
	mark.rutland@arm.com, arnd@arndb.de, suzuki.poulose@arm.com,
	punit.agrawal@arm.com, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Anup Patel <anup.patel@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160424.141806.786009616301278103.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Thanks for providing input over the patch.  Will address the comment as
described below.

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 24 April 2016 23:48
> To: pramod.kumar@broadcom.com
> Cc: robh+dt@kernel.org; catalin.marinas@arm.com; will.deacon@arm.com;
> yamada.masahiro@socionext.com; wens@csie.org; bcm-kernel-feedback-
> list@broadcom.com; pawel.moll@arm.com; mark.rutland@arm.com;
> arnd@arndb.de; suzuki.poulose@arm.com; punit.agrawal@arm.com;
> devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; anup.patel@broadcom.com
> Subject: Re: [PATCH 1/6] bus: Add shared MDIO bus framework
>
> From: Pramod Kumar <pramod.kumar@broadcom.com>
> Date: Thu, 21 Apr 2016 14:48:38 +0530
>
> > +struct shared_mdio_master *shared_mdio_alloc_master(struct device
> *parent,
> > +						    struct device_node
*node)
> > +{
> > +	int ret = 0;
> > +	struct shared_mdio_master *master;
>
> Always order local variable declarations in reverse christmas tree
(longest to
> shortest line) order.
>

Sure. Next patch will address this.

> > +static int shared_mdio_driver_probe(struct device *dev) {
> > +	int rc;
> > +	struct shared_mdio_master *master = to_shared_mdio_master(dev);
> > +	struct shared_mdio_driver *drv =
to_shared_mdio_driver(dev->driver);
>
> Likewise.

Sure.

> Please audit your entire submission for this issue.

Sure. I'll audit the entire patch set for above issue.

Regards,
Pramod
