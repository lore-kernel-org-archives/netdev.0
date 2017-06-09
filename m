From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: add support to change MTU
Date: Fri, 9 Jun 2017 19:31:09 +0300
Message-ID: <15374026-bf82-5b4c-7d1a-53b21dff3451@cogentembedded.com>
References: <20170609153034.8777-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:32780 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751621AbdFIQbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 12:31:12 -0400
Received: by mail-lf0-f52.google.com with SMTP id m77so7180449lfe.0
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 09:31:12 -0700 (PDT)
In-Reply-To: <20170609153034.8777-1-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 06/09/2017 06:30 PM, Niklas Söderlund wrote:

> The hardware supports the MTU to be changed and the driver it self is
> somewhat prepared to support this. This patch hooks up the callbacks to
> be able to change the MTU from user-space.
>
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
[...]

    One more thing off my back, thanks! :-)
    I'm OK with this patch in principle (but have several nits):

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index f68c4db656eda846..da41eda7bfada6b9 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -3171,6 +3184,13 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>  	}
>  	sh_eth_set_default_cpu_data(mdp->cd);
>
> +	/* Datasheet states max MTU should be 2048 but due to the

    User's manual. :-)
    Somehow I thought it supports jumbo frames but the manual doesn't confirm 
that... ah, that's EtherAVB! :-)

> +	 * aliment calculations in sh_eth_ring_init() the practical

   Alignment.

> +	 * MTU is a bit less. Maybe this can be optimized some more.

    Undoubtedly... :-)

[...]

MBR, Sergei
