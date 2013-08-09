From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH][net-next v1] gianfar: Add flow control support
Date: Fri, 9 Aug 2013 14:36:59 -0300
Message-ID: <CAOMZO5CG3L3Jhjki-V7-jc+jBqRca_TTz_3e7=DP_1Zn8apZXQ@mail.gmail.com>
References: <1376036790-18238-2-git-send-email-ljaenicke@innominate.com>
	<1376068786-29868-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Lutz Jaenicke <ljaenicke@innominate.com>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:59440 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758359Ab3HIRhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 13:37:00 -0400
Received: by mail-vc0-f177.google.com with SMTP id gf12so1253374vcb.36
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 10:36:59 -0700 (PDT)
In-Reply-To: <1376068786-29868-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 9, 2013 at 2:19 PM, Claudiu Manoil
<claudiu.manoil@freescale.com> wrote:

> +static int gfar_spauseparam(struct net_device *dev,
> +                           struct ethtool_pauseparam *epause)
> +{
> +       struct gfar_private *priv = netdev_priv(dev);
> +       struct phy_device *phydev = priv->phydev;
> +       struct gfar __iomem *regs = priv->gfargrp[0].regs;
> +       u32 oldadv, newadv;
> +       int err = 0;

You could drop this 'err' variable, no?

...

> +
> +       return err;

Then just 'return 0' here.
