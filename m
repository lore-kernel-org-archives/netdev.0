From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] fec: Add support to restart autonegotiate
Date: Mon, 17 Jun 2013 17:44:46 +0400
Message-ID: <51BF12CE.3090502@cogentembedded.com>
References: <1371427478-25902-1-git-send-email-cphealy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Jim Baxter <jim_baxter@mentor.com>, netdev@vger.kernel.org
To: cphealy@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:33050 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222Ab3FQNou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 09:44:50 -0400
Received: by mail-la0-f43.google.com with SMTP id gw10so2437378lab.2
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 06:44:48 -0700 (PDT)
In-Reply-To: <1371427478-25902-1-git-send-email-cphealy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 17-06-2013 4:04, cphealy@gmail.com wrote:

> From: Chris <cphealy@gmail.com>

> Add ethtool operation to restart autonegotiation via the PHY.

> Also cleanup two whitespace errors that break kernel guidelines.

    This "also" is asking for another patch.

> Tested on i.MX28EVK.

> Signed-off-by: Chris <cphealy@gmail.com>

     You must specify your full name.

> ---
>   drivers/net/ethernet/freescale/fec_main.c | 17 ++++++++++++++---
>   1 file changed, 14 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index a667015..c6be728 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -150,7 +150,7 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
>   #define	FEC_FLASHMAC	0xf0006000
>   #elif defined(CONFIG_CANCam)
>   #define	FEC_FLASHMAC	0xf0020000
> -#elif defined (CONFIG_M5272C3)
> +#elif defined(CONFIG_M5272C3)
>   #define	FEC_FLASHMAC	(0xffe04000 + 4)
>   #elif defined(CONFIG_MOD5272)
>   #define FEC_FLASHMAC	0xffc0406b
> @@ -1206,8 +1206,7 @@ static int fec_enet_mii_probe(struct net_device *ndev)
>   	if (id_entry->driver_data & FEC_QUIRK_HAS_GBIT) {
>   		phy_dev->supported &= PHY_GBIT_FEATURES;
>   		phy_dev->supported |= SUPPORTED_Pause;
> -	}
> -	else
> +	} else
>   		phy_dev->supported &= PHY_BASIC_FEATURES;

    According to Documentation/CodingStyle, *else* branch should have 
{}, as *if* branch has it.

WBR, Sergei
