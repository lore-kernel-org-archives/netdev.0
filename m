From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: [net-next PATCH] bnx2x: Fix link problem with some DACs
Date: Sun, 13 Jun 2010 23:27:55 +0200
Message-ID: <4C154D5B.8000004@ans.pl>
References: <1276429385.13056.13.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:59611 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044Ab0FMV2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jun 2010 17:28:09 -0400
In-Reply-To: <1276429385.13056.13.camel@lb-tlvb-yanivr.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-06-13 13:43, Yaniv Rosner wrote:
> Change 2wire transfer rate of SFP+ module EEPROM from 400Khz to 100Kh=
z since some DACs(direct attached cables) do not work at 400Khz.
>
> Reported-by: Krzysztof Oldzki <ole@ans.pl>
> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
> diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
> index a22a7e0..9b15b64 100644
> --- a/drivers/net/bnx2x_link.c
> +++ b/drivers/net/bnx2x_link.c
> @@ -4274,7 +4274,7 @@ static u8 bnx2x_ext_phy_init(struct link_params=
 *params, struct link_vars *vars)
>   				       ext_phy_addr,
>   				       MDIO_PMA_DEVAD,
>   				       MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
> -				       0xa001);
> +				       0xa101);
>
>   			/* Set TX PreEmphasis if needed */
>   			if ((params->feature_config_flags&

Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>

However, I believe the comment before this code should also be changed,=
=20
because it is now: "Set 2-wire transfer rate to 400Khz since 100Khz
is not operational ".

Thanks.

Best regards,

			Krzysztof Ol=C4=99dzki
