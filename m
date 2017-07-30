From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net v2] MAINTAINERS: Add more files to the PHY LIBRARY
 section
Date: Sat, 29 Jul 2017 17:19:42 -0700
Message-ID: <1501373982.5368.68.camel@perches.com>
References: <20170729004317.31525-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0218.hostedemail.com ([216.40.44.218]:59761 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751888AbdG3ATp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 20:19:45 -0400
In-Reply-To: <20170729004317.31525-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-07-28 at 17:43 -0700, Florian Fainelli wrote:
> Include missing files that are provided by, used, or directly maintained
> within the PHY LIBRARY, this include uapi header, header files used by
> Device Tree code etc.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Changes in v2:
> 
> - added the files Andrew identified and a few more
> - sort by alphabetical order
> 
>  MAINTAINERS | 20 +++++++++++++++++---
>  1 file changed, 17 insertions(+), 3 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 297e610c9163..8e44a637c490 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -5138,12 +5138,26 @@ M:	Andrew Lunn <andrew@lunn.ch>
>  M:	Florian Fainelli <f.fainelli@gmail.com>
>  L:	netdev@vger.kernel.org
>  S:	Maintained
> -F:	include/linux/phy.h
> -F:	include/linux/phy_fixed.h
> -F:	drivers/net/phy/
> +F:	Documentation/ABI/testing/sysfs-bus-mdio
> +F:	Documentation/devicetree/bindings/net/mdio-mux-gpio.txt
> +F:	Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
> +F:	Documentation/devicetree/bindings/net/mdio-mux.txt
> +F:	Documentation/devicetree/bindings/net/mdio.txt

wildcards are useful.  Maybe instead of 4 entries just

F:	Documentation/devicetree/bindings/net/mdio*

>  F:	Documentation/networking/phy.txt
> +F:	drivers/net/phy/
>  F:	drivers/of/of_mdio.c
>  F:	drivers/of/of_net.c
> +F:	include/linux/mdio-bitbang.h
> +F:	include/linux/mdio-mux.h
> +F:	include/linux/mdio.h
> +F:	include/linux/of_mdio.h

And maybe

F:	include/linux/*mdio*.h

> +F:	include/linux/of_net.h
> +F:	include/linux/phy.h
> +F:	include/linux/phy_fixed.h
> +F:	include/linux/platform_data/mdio-gpio.h
> +F:	include/trace/events/mdio.h
> +F:	include/uapi/linux/mdio.h
> +F:	include/uapi/linux/mii.h
>  
>  EXT2 FILE SYSTEM
>  M:	Jan Kara <jack@suse.com>
