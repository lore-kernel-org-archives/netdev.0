From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 6/9] net: mv643xx_eth: use phy_init_hw to reset PHY
Date: Fri, 06 Dec 2013 05:16:30 +0300
Message-ID: <52A1337E.5050002@cogentembedded.com>
References: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com> <1386291317-1202-7-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sebastian.hesselbarth@gmail.com,
	afleming@gmail.com, kyle@moffetthome.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:64328 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab3LFBQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:16:29 -0500
Received: by mail-lb0-f175.google.com with SMTP id x18so11328lbi.6
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 17:16:27 -0800 (PST)
In-Reply-To: <1386291317-1202-7-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/06/2013 03:55 AM, Florian Fainelli wrote:

> Instead of open-coding a PHY reset through the MII BMCR register, use
> phy_init_hw() which does that for us and will also make sure that PHY
> fixups are applied if required.

    You failed to mention that you stopped resetting PHY in phy_init()...

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/net/ethernet/marvell/mv643xx_eth.c | 21 +--------------------
>   1 file changed, 1 insertion(+), 20 deletions(-)

> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index 61088a6..8d9bb6b 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
[...]
> @@ -2764,8 +2747,6 @@ static void phy_init(struct mv643xx_eth_private *mp, int speed, int duplex)
>   {
>   	struct phy_device *phy = mp->phy;
>
> -	phy_reset(mp);
> -
>   	if (speed == 0) {
>   		phy->autoneg = AUTONEG_ENABLE;
>   		phy->speed = 0;
>

WBR, Sergei
