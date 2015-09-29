From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/3] net: irda: pxaficp_ir: convert to readl and
 writel
Date: Mon, 28 Sep 2015 22:33:16 -0700 (PDT)
Message-ID: <20150928.223316.2127100266762141160.davem@davemloft.net>
References: <1443293360-16377-1-git-send-email-robert.jarzmik@free.fr>
	<1443293360-16377-2-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbbI2FdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:33:17 -0400
In-Reply-To: <1443293360-16377-2-git-send-email-robert.jarzmik@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Sat, 26 Sep 2015 20:49:19 +0200

> Convert the pxa IRDA driver to readl and writel primitives, and remove
> another set of direct registers access. This leaves only the DMA
> registers access, which will be dealt with dmaengine conversion.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> Tested-by: Petr Cvek <petr.cvek@tul.cz>
> ---
> Since v1: modified __REG macro to cope with STIER, ST* registers

Applied to net-next.
