From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 18/19] drivers/net/ethernet/marvell: add missing platform_driver
 owne
Date: Tue, 21 May 2013 17:11:43 +0400
Message-ID: <519B728F.2000905@cogentembedded.com>
References: <1369104171-8824-1-git-send-email-libo.chen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lizefan@huawei.com
To: Libo Chen <libo.chen@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:41117 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754232Ab3EUNLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 09:11:45 -0400
Received: by mail-lb0-f174.google.com with SMTP id u10so758376lbi.19
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 06:11:43 -0700 (PDT)
In-Reply-To: <1369104171-8824-1-git-send-email-libo.chen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 21-05-2013 6:42, Libo Chen wrote:

> set the owner of platform_driver, to ensure that the
> caller of driver holds a module refernece

> Signed-off-by: Libo Chen <libo.chen@huawei.com>
> ---
>   drivers/net/ethernet/marvell/mvneta.c |    1 +
>   1 files changed, 1 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index c966785..be35a3e 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -2820,6 +2820,7 @@ static struct platform_driver mvneta_driver = {
>   	.remove = mvneta_remove,
>   	.driver = {
>   		.name = MVNETA_DRIVER_NAME,
> +		.owner	= THIS_MODULE,

    Indent this = with space or indent all ='s with tabs.

>   		.of_match_table = mvneta_match,
>   	},
>   };

WBR, Sergei
