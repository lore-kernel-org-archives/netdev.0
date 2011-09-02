From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next v4 4/4] r8169: support new chips of RTL8111F
Date: Fri, 2 Sep 2011 18:28:31 +0200
Message-ID: <20110902162831.GA25544@electric-eye.fr.zoreil.com>
References: <1314956953-1568-1-git-send-email-hayeswang@realtek.com> <1314956953-1568-4-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38657 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476Ab1IBQrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 12:47:13 -0400
Content-Disposition: inline
In-Reply-To: <1314956953-1568-4-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
> Support new chips of RTL8111F.

Amongst other things :o)

> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 175c769..8e6a200 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -711,7 +719,10 @@ MODULE_FIRMWARE(FIRMWARE_8168D_1);
>  MODULE_FIRMWARE(FIRMWARE_8168D_2);
>  MODULE_FIRMWARE(FIRMWARE_8168E_1);
>  MODULE_FIRMWARE(FIRMWARE_8168E_2);
> +MODULE_FIRMWARE(FIRMWARE_8168E_3);

This one is relevant for Linus's tree.

Don't worry about submitting again, I'll send it separately.

No opinion regarding the jumbo fixes patches I sent on 2011/07/17 ?

-- 
Ueimor
