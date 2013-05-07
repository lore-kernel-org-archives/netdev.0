From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 2/9] net: sh-eth: Add comment to bit of EDSR about
 SH7757
Date: Tue, 07 May 2013 18:48:14 +0400
Message-ID: <5189142E.4000204@cogentembedded.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <1367903875-32606-2-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:34339 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab3EGOsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 10:48:15 -0400
Received: by mail-lb0-f170.google.com with SMTP id t11so825964lbd.29
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 07:48:14 -0700 (PDT)
In-Reply-To: <1367903875-32606-2-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07-05-2013 9:17, Nobuhiro Iwamatsu wrote:

> SH7757 uses EDSR register. This adds about SH7757.

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> ---
>   drivers/net/ethernet/renesas/sh_eth.h |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> index 7ccf58c..71c5559 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -166,7 +166,7 @@ enum {
>   /*
>    * Register's bits
>    */
> -/* EDSR : sh7734, sh7763 and r8a7740 only */
> +/* EDSR : sh7734, sh7763, sh7757 and r8a7740 only */

     Shouldn't SH7763 come after SH7757?

>   enum EDSR_BIT {
>   	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
>   };

    I think you can merge it to patch #1 with a corresponding comment in 
the changelog. This is hardly worth separate patch.

WBR, Sergei
