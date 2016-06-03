From: Pramod Kumar <pramod.kumar@broadcom.com>
Subject: RE: [PATCH v2 5/7] net:mdio-mux: Add MDIO mux driver for iProc SoCs
Date: Fri, 3 Jun 2016 19:17:38 +0530
Message-ID: <373fd6e55d940c4cfd45951dc5bedce7@mail.gmail.com>
References: <1464701801-17243-1-git-send-email-pramod.kumar@broadcom.com>
	<1464701801-17243-6-git-send-email-pramod.kumar@broadcom.com> <20160601.161805.1142999841225463527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	catalin.marinas@arm.com, will.deacon@arm.com, kishon@ti.com,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34590 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538AbcFCNrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 09:47:42 -0400
Received: by mail-io0-f181.google.com with SMTP id p194so75320207iod.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 06:47:41 -0700 (PDT)
In-Reply-To: <20160601.161805.1142999841225463527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 02 June 2016 04:48
> To: pramod.kumar@broadcom.com
> Cc: robh+dt@kernel.org; pawel.moll@arm.com; mark.rutland@arm.com;
> ijc+devicetree@hellion.org.uk; galak@codeaurora.org;
> catalin.marinas@arm.com; will.deacon@arm.com; kishon@ti.com;
> devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
bcm-kernel-
> feedback-list@broadcom.com; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org
> Subject: Re: [PATCH v2 5/7] net:mdio-mux: Add MDIO mux driver for iProc
SoCs
>
> From: Pramod Kumar <pramod.kumar@broadcom.com>
> Date: Tue, 31 May 2016 19:06:39 +0530
>
> > +static int iproc_mdio_wait_for_idle(void __iomem *base, bool result)
> > +{
> > +	u32 val;
> > +	unsigned int timeout = 1000; /* loop for 1s */
>
> Please order your local variable declarations from longest to shortest
line.
>
> > +static int start_miim_ops(void __iomem *base,
> > +			  u16 phyid, u32 reg, u16 val, u32 op) {
> > +	int ret;
> > +	u32 param;
>
> Likewise.
>
Sure. I'll take care of this in next patch for all places.

> > +static int iproc_mdiomux_read(struct mii_bus *bus, int phyid, int
> > +reg) {
> > +	int ret;
> > +	struct iproc_mdiomux_desc *md = bus->priv;
>
> Likewise.
Sure. I'll take care of this in next patch for all places.

Regards,
Pramod
