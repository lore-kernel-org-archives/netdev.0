From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 4/4] net: phy: remove unneeded parenthesis
Date: Fri, 24 Jan 2014 02:37:30 +0400
Message-ID: <52E199AA.7020200@cogentembedded.com>
References: <1390508269-28769-1-git-send-email-f.fainelli@gmail.com> <1390508269-28769-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, joe@perches.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:40713 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbaAWWh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:37:28 -0500
Received: by mail-la0-f53.google.com with SMTP id e16so1965304lan.40
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 14:37:27 -0800 (PST)
In-Reply-To: <1390508269-28769-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 24-01-2014 0:17, Florian Fainelli wrote:

> Our if/else statement in phy_print_status() is only comprised of one
> line for each, remove the parenthesis.

    I protest, the *if* arm is multi-line, though single statement. :-)
Could we avoid changing that code to and fro during 3.14-rc1?

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   drivers/net/phy/phy.c | 5 ++---
>   1 file changed, 2 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 36fc6e1..59aa85e 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -64,15 +64,14 @@ static const char *phy_speed_to_str(int speed)
>    */
>   void phy_print_status(struct phy_device *phydev)
>   {
> -	if (phydev->link) {
> +	if (phydev->link)
>   		netdev_info(phydev->attached_dev,
>   			"Link is Up - %s/%s - flow control %s\n",
>   			phy_speed_to_str(phydev->speed),
>   			DUPLEX_FULL == phydev->duplex ? "Full" : "Half",
>   			phydev->pause ? "rx/tx" : "off");
> -	} else	{
> +	else
>   		netdev_info(phydev->attached_dev, "Link is Down\n");
> -	}
>   }
>   EXPORT_SYMBOL(phy_print_status);

WBR, Sergei
