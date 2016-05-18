From: Michael Hennerich <michael.hennerich@analog.com>
Subject: Re: [PATCH 1/1] net: ieee802154/adf7242: syntax error ifdef DEBUG
Date: Wed, 18 May 2016 08:35:14 +0200
Message-ID: <573C0D22.6060505@analog.com>
References: <1463522320-10964-1-git-send-email-xypron.glpk@gmx.de>
Reply-To: <michael.hennerich@analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-wpan@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Alexander Aring <aar@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463522320-10964-1-git-send-email-xypron.glpk@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/17/2016 11:58 PM, Heinrich Schuchardt wrote:
> If DEBUG is defined, a superfluous closing brace
> is introduced.
>
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>

Acked-by: Michael Hennerich <michael.hennerich@analog.com>

> ---
>   drivers/net/ieee802154/adf7242.c | 1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/drivers/net/ieee802154/adf7242.c b/drivers/net/ieee802154/adf7242.c
> index b82e39d..9fa7ac9 100644
> --- a/drivers/net/ieee802154/adf7242.c
> +++ b/drivers/net/ieee802154/adf7242.c
> @@ -915,7 +915,6 @@ static void adf7242_debug(u8 irq1)
>   		(stat & 0xf) == RC_STATUS_PHY_RDY ? "RC_STATUS_PHY_RDY" : "",
>   		(stat & 0xf) == RC_STATUS_RX ? "RC_STATUS_RX" : "",
>   		(stat & 0xf) == RC_STATUS_TX ? "RC_STATUS_TX" : "");
> -	}
>   #endif
>   }
>
>


-- 
Greetings,
Michael
