From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 1/8] net: sh-eth: Remove ifdef from definition of bit
 of EDSR and GECMR
Date: Thu, 18 Apr 2013 18:50:56 +0400
Message-ID: <51700850.3050906@cogentembedded.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:58481 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967009Ab3DROwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:52:07 -0400
Received: by mail-lb0-f181.google.com with SMTP id r11so2728836lbv.26
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:52:05 -0700 (PDT)
In-Reply-To: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

    Step in the right direction.

> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> index 6f9a997..f86ea96 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -166,19 +166,16 @@ enum {
>   /*
>    * Register's bits
>    */
> -#if defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763) ||\
> -    defined(CONFIG_ARCH_R8A7740)
> -/* EDSR */
> +/* EDSR : sh7734, sh7764, sh7757 and r8a7740 only */

    Where sh7764 and sh7757 came from?

>   enum EDSR_BIT {
>   	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
>   };
>   #define EDSR_ENALL (EDSR_ENT|EDSR_ENR)
>
> -/* GECMR */
> +/* GECMR : sh7734, sh7764 and r8a7740 only */

    Where sh7764 came from?

>   enum GECMR_BIT {
>   	GECMR_10 = 0x0, GECMR_100 = 0x04, GECMR_1000 = 0x01,
>   };
> -#endif

WBR, Sergei
