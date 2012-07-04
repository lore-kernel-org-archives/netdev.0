From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH] bcm87xx: fix reg-init comment typo
Date: Wed, 04 Jul 2012 10:22:38 -0700
Message-ID: <4FF47BDE.3010002@gmail.com>
References: <1341414345-16626-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.daney@cavium.com, davem@davemloft.net
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:43105 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972Ab2GDRWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 13:22:42 -0400
Received: by gglu4 with SMTP id u4so6660133ggl.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 10:22:42 -0700 (PDT)
In-Reply-To: <1341414345-16626-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/04/2012 08:05 AM, Peter Korsgaard wrote:
> broadcom, not marvell.
>
> Signed-off-by: Peter Korsgaard<jacmet@sunsite.dk>

Indeed, it was a cut-and-paste error.  Thanks for fixing it...

Acked-by: David Daney <david.daney@cavium.com>

> ---
>   drivers/net/phy/bcm87xx.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
> index 9a90dcf..a6df68c 100644
> --- a/drivers/net/phy/bcm87xx.c
> +++ b/drivers/net/phy/bcm87xx.c
> @@ -22,7 +22,7 @@
>
>   #if IS_ENABLED(CONFIG_OF_MDIO)
>   /* Set and/or override some configuration registers based on the
> - * marvell,reg-init property stored in the of_node for the phydev.
> + * broadcom,c45-reg-init property stored in the of_node for the phydev.
>    *
>    * broadcom,c45-reg-init =<devid reg mask value>,...;
>    *
