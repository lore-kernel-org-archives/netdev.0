From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 12/12] smc911x: afc_cfg calculation is wrong at case 5
Date: Wed, 13 Sep 2006 21:02:34 +0200
Message-ID: <20060913190234.GG25007@electric-eye.fr.zoreil.com>
References: <200609132137.47905.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:18828 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751112AbWIMTFJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 15:05:09 -0400
To: bora.sahin@ttnet.net.tr
Content-Disposition: inline
In-Reply-To: <200609132137.47905.bora.sahin@ttnet.net.tr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
[...]
> BACKDUR  calculation is wrong at case 5. Also some cosmetic around
> smc911x_probe...

If you are in a mood for cosmetic, feel free to turn some unsigned
long ioaddr into something more void __iomem *ioaddr and store it
in the private part of the device struct instead of dev->base_addr.

[...]
> @@ -1977,7 +1975,7 @@
>  		case 4:/* 11520 Rx Data Fifo Size */
>  			lp->afc_cfg=0x00783C9F;break;
>  		case 5:/* 10560 Rx Data Fifo Size */
> -			lp->afc_cfg=0x006E374F;break;
> +			lp->afc_cfg=0x006E378F;break;

Not your fault but the break statement is misplaced.

-- 
Ueimor
