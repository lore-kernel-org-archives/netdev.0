From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smc91x: use run-time configuration on all ARM
 machines
Date: Sat, 28 Feb 2015 12:57:21 -0500 (EST)
Message-ID: <20150228.125721.1605776377351425463.davem@davemloft.net>
References: <2226303.iMQTNXSl1n@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, robert.jarzmik@free.fr,
	linus.walleij@linaro.org, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbbB1R50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 12:57:26 -0500
In-Reply-To: <2226303.iMQTNXSl1n@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 25 Feb 2015 16:31:57 +0100

> The smc91x driver traditionally gets configured at compile-time
> for whichever hardware it runs on. This no longer works on
> ARM as we continue to move to building all-in-one kernels.
> 
> Most ARM configurations with this driver already use run-time
> configuration through DT or through platform_data, but a
> few have not been converted yet.
> 
> I've checked all ARM boards that use this driver in their
> legacy board files, and converted the ones that were using
> compile-time configuration in smc91x.h to behave like the
> other ones and provide the interrupt polarity along with
> the MMIO configuration (width, stride) at platform device
> creation time.
> 
> In particular, these combinations were previously selectable
> in Kconfig but in fact broken:
> 
> - sa1100 assabet plus pleb
> - msm combined with any other armv6/v7 platform
> - pxa-idp combined with any non-DMA pxa variant
> - LogicPD PXA270 combined with any other pxa
> - nomadik combined with any other armv4/v5 platform,
>   e.g. versatile.
> 
> None of these seem critical enough to warrant a backport
> to stable, but it would be nice to clean this up for good.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
