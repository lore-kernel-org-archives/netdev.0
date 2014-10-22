From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/6] ethernet: wiznet: remove unnecessary check
Date: Wed, 22 Oct 2014 15:44:46 +0400
Message-ID: <544798AE.1040209@cogentembedded.com>
References: <N> <1413951386-29645-1-git-send-email-varkab@cdac.in> <1413951386-29645-3-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:40271 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932729AbaJVLot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 07:44:49 -0400
Received: by mail-la0-f41.google.com with SMTP id pn19so2780277lab.28
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 04:44:47 -0700 (PDT)
In-Reply-To: <1413951386-29645-3-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2014 8:16 AM, Varka Bhadram wrote:

> devm_ioremap_resource checks platform_get_resource() return value.
> We can remove the duplicate check here.

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>   drivers/net/ethernet/wiznet/w5300.c |    3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)

> diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
> index f961f14..315d090 100644
> --- a/drivers/net/ethernet/wiznet/w5300.c
> +++ b/drivers/net/ethernet/wiznet/w5300.c
> @@ -558,8 +558,7 @@ static int w5300_hw_probe(struct platform_device *pdev)
>   	}
>
>   	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -	if (!mem)
> -		return -ENXIO;
> +
>   	mem_size = resource_size(mem);

    Same problem as in the patch #1

>
>   	priv->base = devm_ioremap_resource(&pdev->dev, mem);
>

WBR, Sergei
