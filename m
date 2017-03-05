From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: phy: Add dependencies for Cavium SoCs
Date: Sun, 5 Mar 2017 16:06:16 +0100
Message-ID: <20170305150616.GA11251@lunn.ch>
References: <20170305121434.22674-1-pbrobinson@gmail.com>
 <20170305121434.22674-2-pbrobinson@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Peter Robinson <pbrobinson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60348 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751060AbdCEPlm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 5 Mar 2017 10:41:42 -0500
Content-Disposition: inline
In-Reply-To: <20170305121434.22674-2-pbrobinson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 05, 2017 at 12:14:33PM +0000, Peter Robinson wrote:
> Add dependencies on the Cavium architectures for the PHYs

Hi Peter

These are not PHY drivers, but MDIO bus drivers. 

> as well as COMPILE_TEST to ensure build coverage.
> 
> Signed-off-by: Peter Robinson <pbrobinson@gmail.com>
> ---
>  drivers/net/phy/Kconfig | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index 8dbd59b..59b8313 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -127,7 +127,7 @@ config MDIO_MOXART
>  
>  config MDIO_OCTEON
>  	tristate "Octeon and some ThunderX SOCs MDIO buses"
> -	depends on 64BIT

Have you tried building this on a 32 bit system with COMPILE_TEST?  I
just wondering why this 64BIT depends is here.

     Andrew
