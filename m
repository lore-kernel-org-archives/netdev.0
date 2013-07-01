From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v3 3/3] sh_eth: Add support for r8a7790 SoC
Date: Mon, 01 Jul 2013 18:30:12 +0400
Message-ID: <51D19274.4060608@cogentembedded.com>
References: <1372652695-16606-1-git-send-email-horms+renesas@verge.net.au> <1372652695-16606-4-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:41176 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab3GAOaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 10:30:17 -0400
Received: by mail-la0-f43.google.com with SMTP id gw10so4468796lab.16
        for <netdev@vger.kernel.org>; Mon, 01 Jul 2013 07:30:16 -0700 (PDT)
In-Reply-To: <1372652695-16606-4-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01-07-2013 8:24, Simon Horman wrote:

> This is a copy of support for r8a7778/9 with the .rmiimode mode bit
> of struct sh_eth_cpu_data set.

> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

> ---

> v3
> * Add r8a7790_data rather than updating r8a777x_data.
>    As requested by Sergei Shtylyov.

> v2
> * Split from "sh_eth: add support RMIIMODE register"
> ---
>   drivers/net/ethernet/renesas/Kconfig  |  2 +-
>   drivers/net/ethernet/renesas/sh_eth.c | 21 +++++++++++++++++++++
>   2 files changed, 22 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/renesas/Kconfig b/drivers/net/ethernet/renesas/Kconfig
> index 544514e..0d8a124a 100644
> --- a/drivers/net/ethernet/renesas/Kconfig
> +++ b/drivers/net/ethernet/renesas/Kconfig
> @@ -12,4 +12,4 @@ config SH_ETH
>   	  Renesas SuperH Ethernet device driver.
>   	  This driver supporting CPUs are:
>   		- SH7619, SH7710, SH7712, SH7724, SH7734, SH7763, SH7757,
> -		  R8A7740 and R8A7779.
> +		  R8A7740, R8A7779 and R8A7790.

    Could you s/R8A7779/R8A777x/, while at it?

WBR, Sergei
