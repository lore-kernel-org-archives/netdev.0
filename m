From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 5/7] net: of_mdio: parse "max-speed" property to set PHY
 supported features
Date: Fri, 06 Dec 2013 03:49:04 +0300
Message-ID: <52A11F00.1070603@cogentembedded.com>
References: <1386283936-26104-1-git-send-email-florian@openwrt.org> <1386283936-26104-6-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, grant.likely@linaro.org,
	devicetree@vger.kernel.org, abrodkin@synopsys.com,
	rob.herring@calxeda.com, mark.rutland@arm.com,
	sebastian.hesselbarth@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:62520 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab3LEXtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:49:03 -0500
Received: by mail-la0-f50.google.com with SMTP id el20so10865987lab.9
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 15:49:01 -0800 (PST)
In-Reply-To: <1386283936-26104-6-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/06/2013 01:52 AM, Florian Fainelli wrote:

> From: Florian Fainelli <f.fainelli@gmail.com>

> The "max-speed" property is defined per the ePAPR specification to
> express the maximum speed a PHY supports. Use that property, if present
> to set the phydev->supported features which properly restricts the PHY
> within the range of defined speeds.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/of/of_mdio.c | 25 ++++++++++++++++++++++++-
>   1 file changed, 24 insertions(+), 1 deletion(-)

> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 4923ab2..e1e19e5 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
[...]
> @@ -58,8 +76,13 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>   		return 1;
>   	}
>
> +	/* Set phydev->supported based on the "max-speed" property
> +	 * if present */

    Preferred multi-line comment style is this:

/*
  * bla
  * bla
  */

WBR, Sergei
