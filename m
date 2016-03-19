From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: smc911x: convert pxa dma to dmaengine
Date: Fri, 18 Mar 2016 22:25:03 -0400 (EDT)
Message-ID: <20160318.222503.1989588105611694828.davem@davemloft.net>
References: <1458149162-11469-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fabio.estevam@nxp.com
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458149162-11469-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Wed, 16 Mar 2016 18:26:02 +0100

> Convert the dma transfers to be dmaengine based, now pxa has a dmaengine
> slave driver. This makes this driver a bit more PXA agnostic.
> 
> The driver was only compile tested. The risk is quite small as no
> current PXA platform I'm aware of is using smc911x driver.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> Tested-by: Fabio Estevam <fabio.estevam@nxp.com>
> ---
> Since v1: added Fabio's Tested-by

Applied, thanks.
