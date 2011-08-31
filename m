From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 8/8] tg3: Code movement
Date: Wed, 31 Aug 2011 16:59:50 -0700
Message-ID: <1314835190.27632.22.camel@Joe-Laptop>
References: <1314827094-29714-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42179 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755871Ab1HaX7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 19:59:52 -0400
In-Reply-To: <1314827094-29714-9-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-31 at 14:44 -0700, Matt Carlson wrote:
> This patch just moves some code around for better organization.
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
[]
> @@ -15541,7 +15542,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
>  		tnapi->tx_pending = TG3_DEF_TX_RING_PENDING;
>  
>  		tnapi->int_mbox = intmbx;
> -		if (i < 4)
> +		if (i <= 4)
>  			intmbx += 0x8;
>  		else
>  			intmbx += 0x4;

Not just code movement.
