From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 4/9] net: sh-eth: Remove duplicate sh_eth_set_duplex()
Date: Tue, 07 May 2013 18:52:22 +0400
Message-ID: <51891526.4090806@cogentembedded.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <1367903875-32606-4-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:64686 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778Ab3EGOwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 10:52:23 -0400
Received: by mail-lb0-f172.google.com with SMTP id y6so830168lbh.31
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 07:52:22 -0700 (PDT)
In-Reply-To: <1367903875-32606-4-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07-05-2013 9:17, Nobuhiro Iwamatsu wrote:

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> ---
> V3:
>    Remove sh_eth_set_duplex from SH7619, SH7710 and SH7712.
> V2:
>    no change.
>   drivers/net/ethernet/renesas/sh_eth.c |   57 +++------------------------------
>   1 file changed, 4 insertions(+), 53 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 334fa13..944b2df 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -341,9 +341,6 @@ static void sh_eth_select_mii(struct net_device *ndev)
>   }
>   #endif
>
> -/* There is CPU dependent code */
> -#if defined(CONFIG_ARCH_R8A7778) || defined(CONFIG_ARCH_R8A7779)
> -#define SH_ETH_RESET_DEFAULT	1
>   static void sh_eth_set_duplex(struct net_device *ndev)

     I think you need to annotate this function with __maybe_unused as 
well since some SoC don't use it.

WBR, Sergei
