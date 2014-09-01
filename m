From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sh_eth: fix driver dependencies
Date: Mon, 01 Sep 2014 17:21:42 +0400
Message-ID: <540472E6.7020901@cogentembedded.com>
References: <3693021.H9Y3NelqF1@amdc1032>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Kyungmin Park <kyungmin.park@samsung.com>,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:54199 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008AbaIANVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 09:21:43 -0400
Received: by mail-la0-f44.google.com with SMTP id hz20so6106072lab.17
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 06:21:41 -0700 (PDT)
In-Reply-To: <3693021.H9Y3NelqF1@amdc1032>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/1/2014 5:15 PM, Bartlomiej Zolnierkiewicz wrote:

> Renesas SuperH Ethernet support should be available only on
> Renesas ARM SoCs and SuperH architecture.

> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Magnus Damm <magnus.damm@gmail.com>
> ---
>   drivers/net/ethernet/renesas/Kconfig |    1 +
>   1 file changed, 1 insertion(+)

> Index: b/drivers/net/ethernet/renesas/Kconfig
> ===================================================================
> --- a/drivers/net/ethernet/renesas/Kconfig	2014-07-30 14:31:20.479522692 +0200
> +++ b/drivers/net/ethernet/renesas/Kconfig	2014-09-01 14:45:36.160544016 +0200
> @@ -5,6 +5,7 @@
>   config SH_ETH
>   	tristate "Renesas SuperH Ethernet support"
>   	depends on HAS_DMA
> +	depends on ARCH_SHMOBILE || ARCH_SH || COMPILE_TEST

    s/ARCH-SH/SUPERH/ perhaps?

WBR, Sergei
