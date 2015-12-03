From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc911x: convert pxa dma to dmaengine
Date: Wed, 02 Dec 2015 23:52:17 -0500 (EST)
Message-ID: <20151202.235217.2201517065767030121.davem@davemloft.net>
References: <1448919628-13273-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448919628-13273-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Mon, 30 Nov 2015 22:40:28 +0100

> Convert the dma transfers to be dmaengine based, now pxa has a dmaengine
> slave driver. This makes this driver a bit more PXA agnostic.
> 
> The driver was only compile tested. The risk is quite small as no
> current PXA platform I'm aware of is using smc911x driver.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>

I've marked this 'deferred' in patchwork until someone tests
these changes and says they should be good on all platforms
this chip is used.
