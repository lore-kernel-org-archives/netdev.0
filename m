From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1 1/6] net: phy: broadcom: add bcm54220 phy ID
Date: Wed, 19 Aug 2015 14:28:54 -0700
Message-ID: <CAGVrzcak2u_kBg1o061OO0UK8sdrXaKF+-7eREwByD-dQ1r1XQ@mail.gmail.com>
References: <1439962444-27486-1-git-send-email-b38611@freescale.com> <1439962444-27486-2-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: shawnguo@kernel.org, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36046 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbbHSV3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 17:29:35 -0400
Received: by iodv127 with SMTP id v127so24743047iod.3
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 14:29:34 -0700 (PDT)
In-Reply-To: <1439962444-27486-2-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-08-18 22:33 GMT-07:00 Fugang Duan <b38611@freescale.com>:
> Add bcm54220 phy ID entry.

This change itself is fine, but looking at the rest of your changes,
we are not adding an entry for this PHY in drivers/net/phy/broadcom.c,
which means that we will bind to the Generic PHY driver, and so this
looks sufficient, even with your fixup done in the subsequent patch.

>
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> ---
>  include/linux/brcmphy.h | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
> index 697ca77..20bed15 100644
> --- a/include/linux/brcmphy.h
> +++ b/include/linux/brcmphy.h
> @@ -16,6 +16,7 @@
>  #define PHY_ID_BCM5482                 0x0143bcb0
>  #define PHY_ID_BCM5411                 0x00206070
>  #define PHY_ID_BCM5421                 0x002060e0
> +#define PHY_ID_BCM54220                        0x600d8589
>  #define PHY_ID_BCM5464                 0x002060b0
>  #define PHY_ID_BCM5461                 0x002060c0
>  #define PHY_ID_BCM54616S               0x03625d10
> --
> 1.9.1
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



-- 
Florian
