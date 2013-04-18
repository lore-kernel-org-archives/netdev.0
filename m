From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 7/8] net: sh-eth: Remove ifdef for sh_eth_select_mii
Date: Thu, 18 Apr 2013 18:36:45 +0400
Message-ID: <517004FD.9060906@cogentembedded.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <1366279869-23387-7-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:43078 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965340Ab3DROhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:37:55 -0400
Received: by mail-lb0-f177.google.com with SMTP id r10so2724783lbi.22
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:37:54 -0700 (PDT)
In-Reply-To: <1366279869-23387-7-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

    That's what I was going to do first.

>   drivers/net/ethernet/renesas/sh_eth.c |    4 ----
>   1 file changed, 4 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index a4e337f..eb428d4 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -313,9 +313,6 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
>   	[TSU_ADRL31]	= 0x01fc,
>   };
>
> -#if defined(CONFIG_CPU_SUBTYPE_SH7734) || \
> -	defined(CONFIG_CPU_SUBTYPE_SH7763) || \
> -	defined(CONFIG_ARCH_R8A7740)
>   static void sh_eth_select_mii(struct net_device *ndev)

    Don't you want to annotate the function with __maybe_unused?

WBR, Sergei
