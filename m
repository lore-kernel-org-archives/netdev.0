From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 2/5] sh_eth: enable wake-on-lan for Gen2 devices
Date: Wed, 14 Dec 2016 16:37:48 +0300
Message-ID: <eeff27f9-25eb-a981-33a9-15aa98ce9db1@cogentembedded.com>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
 <20161212160931.6478-3-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:33924 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755897AbcLNNhw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 08:37:52 -0500
Received: by mail-qt0-f169.google.com with SMTP id n6so22450631qtd.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 05:37:51 -0800 (PST)
In-Reply-To: <20161212160931.6478-3-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

    You forgot "R-Car" before "Gen2" in the subject.

On 12/12/2016 07:09 PM, Niklas Söderlund wrote:

> Tested on Gen2 r8a7791/Koelsch.
>
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 87640b9..348ed22 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -624,8 +624,9 @@ static struct sh_eth_cpu_data r8a779x_data = {
>
>  	.register_type	= SH_ETH_REG_FAST_RCAR,
>
> -	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
> -	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
> +	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD | ECSR_MPD,
> +	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP |
> +			  ECSIPR_MPDIP,

   These expressions seem to have been sorted by the bit # before your patch, 
now they aren't... care to fix? :-)

[...]

MBR, Sergei
