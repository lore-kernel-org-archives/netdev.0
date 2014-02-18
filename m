From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH] net: ethernet: remove unneeded dependency of mvneta
 and update help text
Date: Tue, 18 Feb 2014 07:29:52 -0500
Message-ID: <20140218122952.GM7862@titan.lakedaemon.net>
References: <1392719391-8851-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:21164 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039AbaBRMaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 07:30:07 -0500
Content-Disposition: inline
In-Reply-To: <1392719391-8851-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 18, 2014 at 11:29:51AM +0100, Thomas Petazzoni wrote:
> With the introduction of the support for Armada 375 and Armada 38x,
> the hidden Kconfig option MACH_ARMADA_370_XP is being renamed to
> MACH_MVEBU_V7. Therefore, the dependency that was used for the mvneta
> driver can no longer work.
> 
> However, such a dependency is not really necessary: there is no point
> in preventing this driver from being built in other situations, just
> like the mv643xx_eth driver. As a consequence, this commit removes the
> unnecessary Kconfig dependency.
> 
> In addition to this, it takes this opportunity to adjust the
> description and help text to indicate that the driver can is also used
> for Armada 38x. Note that Armada 375 cannot use this driver as it has
> a completely different networking unit, which will require a separate
> driver.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/Kconfig | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
> index 6300fd2..97b91f7 100644
> --- a/drivers/net/ethernet/marvell/Kconfig
> +++ b/drivers/net/ethernet/marvell/Kconfig
> @@ -43,12 +43,11 @@ config MVMDIO
>  	  This driver is used by the MV643XX_ETH and MVNETA drivers.
>  
>  config MVNETA
> -	tristate "Marvell Armada 370/XP network interface support"
> -	depends on MACH_ARMADA_370_XP

Have you build-tested this on the usual fail scenarios?  eg x86_64,
powerpc, s390, allno, allyes, allmod, etc?

I think you might be opening up pandora's box here without needing to.
:)

thx,

Jason.
