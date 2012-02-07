From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH] net: fec: Fix build due to wrong dev annotation
Date: Wed, 8 Feb 2012 00:42:45 +0530
Message-ID: <CA+Dx6HY0G8f0WkvGaGKZm1YdxknU-FLo5Z+9x_62HwCF7Lb5LQ@mail.gmail.com>
References: <1328639251-26310-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, kernel@pengutronix.de,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:62277 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755527Ab2BGTMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 14:12:47 -0500
Received: by lagu2 with SMTP id u2so4334647lag.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 11:12:45 -0800 (PST)
In-Reply-To: <1328639251-26310-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2012 at 11:57 PM, Fabio Estevam <festevam@gmail.com> wrote:
> commit 21a4e469 (netdev: ethernet dev_alloc_skb to netdev_alloc_skb)
> should have used "ndev" instead of "dev".
>
> This causes the following build errors:
>
> drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_rx':
> drivers/net/ethernet/freescale/fec.c:714: error: 'dev' undeclared (first use in this function)
> drivers/net/ethernet/freescale/fec.c:714: error: (Each undeclared identifier is reported only once
> drivers/net/ethernet/freescale/fec.c:714: error: for each function it appears in.)
> drivers/net/ethernet/freescale/fec.c: In function 'fec_enet_alloc_buffers':
> drivers/net/ethernet/freescale/fec.c:1213: error: 'dev' undeclared (first use in this function)
>
> Fix it, so that fec driver can be built again.
>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---

Thanks a lot, Fabio!

Regards,
Pradeep A. Dalvi
