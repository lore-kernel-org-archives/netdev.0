From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 5/8] net: sh-eth: Add CONFIG_PM to definition of dev_pm_ops
Date: Thu, 18 Apr 2013 18:53:09 +0400
Message-ID: <517008D5.8020309@cogentembedded.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <1366279869-23387-5-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:57773 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967009Ab3DROyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:54:19 -0400
Received: by mail-lb0-f174.google.com with SMTP id s10so2794970lbi.19
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:54:18 -0700 (PDT)
In-Reply-To: <1366279869-23387-5-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[...]

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 7de0b0e..af8c225 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -2785,17 +2786,21 @@ static int sh_eth_runtime_nop(struct device *dev)
>   	return 0;
>   }
>
> -static struct dev_pm_ops sh_eth_dev_pm_ops = {
> +static const struct dev_pm_ops sh_eth_dev_pm_ops = {
>   	.runtime_suspend = sh_eth_runtime_nop,
>   	.runtime_resume = sh_eth_runtime_nop,
>   };
> +#define SH_ETH_PM_OPS &sh_eth_dev_pm_ops

    scripts/checkpatch.pl would complain here about missing (), I heard.
Did you run it?

WBR, Sergei
