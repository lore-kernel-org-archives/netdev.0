From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH v2 bluetooth-next] cc2520: set the default fifo pin value
 from platform data
Date: Tue, 11 Aug 2015 08:48:20 +0530
Message-ID: <55C9697C.7080906@gmail.com>
References: <1439260985-5173-1-git-send-email-sdliyong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: sdliyong@gmail.com, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35389 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933326AbbHKDSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 23:18:32 -0400
In-Reply-To: <1439260985-5173-1-git-send-email-sdliyong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/11/2015 08:13 AM, sdliyong@gmail.com wrote:
> From: Yong Li <sdliyong@gmail.com>
>
> When the device tree support is disabled, the fifo_pin is uninitialized,
> this patch will set the fifo_pin value based on platform data
>
> Signed-off-by: Yong Li <sdliyong@gmail.com>

Acked-by: Varka Bhadram <varkabhadram@gmail.com>

> ---
>   drivers/net/ieee802154/cc2520.c | 1 +
>   1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
> index 613dae5..c5b54a1 100644
> --- a/drivers/net/ieee802154/cc2520.c
> +++ b/drivers/net/ieee802154/cc2520.c
> @@ -833,6 +833,7 @@ static int cc2520_get_platform_data(struct spi_device *spi,
>   		if (!spi_pdata)
>   			return -ENOENT;
>   		*pdata = *spi_pdata;
> +		priv->fifo_pin = pdata->fifo;
>   		return 0;
>   	}
>   

-- 
Varka Bhadram.
