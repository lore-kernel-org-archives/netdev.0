From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] smc91x Hitachi Solution Engine (SuperH) Support
Date: Sat, 29 Sep 2007 15:35:36 +0900
Message-ID: <20070929063536.GB1395@linux-sh.org>
References: <20070919210752.5b211317.iwamatsu@nigauri.org> <46FDE2B5.8050803@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>, netdev@vger.kernel.org,
	nico@cam.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ocgnet.org ([64.20.243.3]:35534 "EHLO smtp.ocgnet.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439AbXI2Gf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 02:35:57 -0400
Content-Disposition: inline
In-Reply-To: <46FDE2B5.8050803@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 29, 2007 at 01:29:25AM -0400, Jeff Garzik wrote:
> Nobuhiro Iwamatsu wrote:
> >This patch supports Hitachi Solution Engine (SuperH) of smc91x. 
> >Please apply this patch .
> 
> >diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
> >index 6ff3a16..af9e6bf 100644
> >--- a/drivers/net/smc91x.h
> >+++ b/drivers/net/smc91x.h
> >@@ -284,6 +284,7 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
> > #elif   defined(CONFIG_SUPERH)
> > 
> > #ifdef CONFIG_SOLUTION_ENGINE
> >+#define SMC_IRQ_FLAGS		(0)
> > #define SMC_CAN_USE_8BIT       0
> > #define SMC_CAN_USE_16BIT      1
> > #define SMC_CAN_USE_32BIT      0
> 
> 
> Does the SuperH maintainer ACK this?

Acked-by: Paul Mundt <lethal@linux-sh.org>
