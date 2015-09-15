From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc91x: convert pxa dma to dmaengine
Date: Tue, 15 Sep 2015 16:24:14 -0700 (PDT)
Message-ID: <20150915.162414.1153837609419205002.davem@davemloft.net>
References: <1441913164-3785-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, linux@arm.linux.org.uk, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441913164-3785-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Jarzmik <robert.jarzmik@free.fr>
Date: Thu, 10 Sep 2015 21:26:04 +0200

> Convert the dma transfers to be dmaengine based, now pxa has a dmaengine
> slave driver. This makes this driver a bit more PXA agnostic.
> 
> The driver was tested on pxa27x (mainstone) and pxa310 (zylonite),
> ie. only pxa platforms.
> 
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: Arnd Bergmann <arnd@arndb.de>
> ---
> This has potential to break other platform such as Neponset, Idp,
> halibut and qsd8x50, so I added Russell and Arnd as they were discussing
> smc91x support last February.

Is someone testing whether such platforms break or not?  I'm waiting for
that before I consider applying this patch.
