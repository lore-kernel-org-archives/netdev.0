From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] MAINTAINERS: add entry for the PHY library
Date: Fri, 21 Feb 2014 14:41:21 +0000
Message-ID: <53076591.4040006@codethink.co.uk>
References: <1392745669-26645-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Grant Likely <grant.likely@linaro.org>,
	Shaohui Xie <shaohui.xie@freescale.com>,
	Andy Fleming <afleming@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:34288 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754396AbaBUOlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 09:41:24 -0500
In-Reply-To: <1392745669-26645-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/02/14 17:47, Florian Fainelli wrote:
> The PHY library has been subject to some changes, new drivers and DT
> interactions over the past few months. Add myself as a maintainer for
> the core PHY library parts and drivers. Make sure the PHY library entry
> also covers the Device Tree files which have a close interaction with
> the MDIO bus, PHY connection and Ethernet PHY mode parsing.
>
> CC: Grant Likely <grant.likely@linaro.org>
> CC: Shaohui Xie <shaohui.xie@freescale.com>
> CC: Andy Fleming <afleming@gmail.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   MAINTAINERS | 11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 5a7b3ec..2bfdb79 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3330,6 +3330,17 @@ S:	Maintained
>   F:	include/linux/netfilter_bridge/
>   F:	net/bridge/
>
> +ETHERNET PHY LIBRARY
> +M:	Florian Fainelli <f.fainelli@gmail.com>
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	include/linux/phy.h
> +F:	include/linux/phy_fixed.h
> +F:	drivers/net/phy/
> +F:	Documentation/networking/phy.txt
> +F:	drivers/of/of_mdio.c
> +F:	drivers/of/of_net.c

Did you miss out:
  Documentation/devicetree/bindings/net/phy.txt



-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
