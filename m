From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] DaVinci EMAC: correct param for ISR
Date: Wed, 04 Nov 2009 05:45:19 -0800 (PST)
Message-ID: <20091104.054519.24849195.davem@davemloft.net>
References: <4AEF8CD6.9060804@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khilman@deeprootsystems.com,
	davinci-linux-open-source-bounces@linux.davincidsp.com,
	netdev@vger.kernel.org
To: Bo.Liu@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52936
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755651AbZKDNoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 08:44:54 -0500
In-Reply-To: <4AEF8CD6.9060804@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tonyliu <Bo.Liu@windriver.com>
Date: Tue, 03 Nov 2009 09:52:22 +0800

> Subject: [PATCH 1/1] DaVinci EMAC: correct param for ISR
> 
> emac_irq is declared as:
> 
> static irqreturn_t emac_irq(int irq, void *dev_id)
> {
>        struct net_device *ndev = (struct net_device *)dev_id;
>        struct emac_priv *priv = netdev_priv(ndev);
>     ... 
> 
> 	Clearly emac_irq() needs "struct net_device *" as "void *dev_id", so correct this.
> 
> Signed-off-by: Tonyliu <Bo.Liu@windriver.com>

Applied to net-2.6, thank you.
