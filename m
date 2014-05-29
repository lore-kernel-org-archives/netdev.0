From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] mrf24j40: add managed API's provided by device layer
Date: Thu, 29 May 2014 21:45:33 +0400
Message-ID: <5387723D.9020009@cogentembedded.com>
References: <1401337071-4071-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	alex.aing@gmail.com, Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>, alan@signal11.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:34545 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932856AbaE2Rp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 13:45:28 -0400
Received: by mail-lb0-f178.google.com with SMTP id w7so387675lbi.9
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 10:45:26 -0700 (PDT)
In-Reply-To: <1401337071-4071-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/29/2014 08:17 AM, Varka Bhadram wrote:

> This patch adds the managed APIs to the deriver code. By using this we need
> not to worry about freeing the memory and irq numbers.

> Thanks and Regards,
> Varka Bhadram

    This is not desirable thing in the patch changelog, maintainer will have 
to edit it out...

> Signed-off-by: Varka Bhadram <varkab@cdac.in>
> ---
>   drivers/net/ieee802154/mrf24j40.c |   22 ++++++++++------------
>   1 file changed, 10 insertions(+), 12 deletions(-)

> diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
> index 78a6552..729ec0f 100644
> --- a/drivers/net/ieee802154/mrf24j40.c
> +++ b/drivers/net/ieee802154/mrf24j40.c
> @@ -618,10 +618,11 @@ static int mrf24j40_probe(struct spi_device *spi)
>
>   	printk(KERN_INFO "mrf24j40: probe(). IRQ: %d\n", spi->irq);
>
> -	devrec = kzalloc(sizeof(struct mrf24j40), GFP_KERNEL);
> +	devrec = devm_kzalloc(spi->dev,
> +			sizeof(struct mrf24j40), GFP_KERNEL);

    Continuation line should start under the next character after ( on the 
previous line, according to the networking coding style.

[...]

WBR, Sergei
