From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 3/8] net: mvmdio: use GENMASK for masks
Date: Thu, 8 Jun 2017 13:35:38 +0300
Message-ID: <6b94a360-dcc7-a78c-819b-4f3c87cf3c6c@cogentembedded.com>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-4-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34407 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdFHKfl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 06:35:41 -0400
Received: by mail-lf0-f48.google.com with SMTP id v20so16253066lfa.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 03:35:40 -0700 (PDT)
In-Reply-To: <20170608092653.25221-4-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 6/8/2017 12:26 PM, Antoine Tenart wrote:

> Cosmetic patch to use the GENMASK helper for masks.
>
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/marvell/mvmdio.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
> index 17b518b13ae3..96af8d57d9e5 100644
> --- a/drivers/net/ethernet/marvell/mvmdio.c
> +++ b/drivers/net/ethernet/marvell/mvmdio.c
> @@ -138,7 +138,7 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
>  		goto out;
>  	}
>
> -	ret = val & 0xFFFF;
> +	ret = val & GENMASK(15,0);

    Need a space after comma.

MBR, Sergei
