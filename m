From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH] net: hip04: add missing MODULE_LICENSE
Date: Sat, 31 Jan 2015 09:28:30 +0800
Message-ID: <54CC2FBE.9090107@huawei.com>
References: <4018099.9I7f6kd5jC@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Zhangfei Gao <zhangfei.gao@linaro.org>
To: Arnd Bergmann <arnd@arndb.de>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:57042 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761549AbbAaBcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 20:32:06 -0500
In-Reply-To: <4018099.9I7f6kd5jC@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/1/31 5:57, Arnd Bergmann wrote:
> The hip04 ethernet driver causes a new compile-time warning
> when built as a loadable module:
> 
> WARNING: modpost: missing MODULE_LICENSE() in drivers/net/ethernet/hisilicon/hip04_eth.o
> see include/linux/module.h for more information
> 
> This adds the license as "GPL", which matches the header of the file.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> 
> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
> index c02b81bcfffb..b72d238695d7 100644
> --- a/drivers/net/ethernet/hisilicon/hip04_eth.c
> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
> @@ -968,3 +968,4 @@ static struct platform_driver hip04_mac_driver = {
>  module_platform_driver(hip04_mac_driver);
>  
>  MODULE_DESCRIPTION("HISILICON P04 Ethernet driver");
> +MODULE_LICENSE("GPL");
> 
> 
Good catch.

Acked-by: Ding Tianhong <dingtianhong@huawei.com>

> 
