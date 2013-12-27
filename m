From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 3/6] r8152: change some definitions
Date: Fri, 27 Dec 2013 19:57:55 +0100
Message-ID: <20131227185755.GA29006@electric-eye.fr.zoreil.com>
References: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
 <1388111649-1014-4-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57426 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044Ab3L0S6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 13:58:03 -0500
Content-Disposition: inline
In-Reply-To: <1388111649-1014-4-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Wang <hayeswang@realtek.com> :
[...]
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index b8bc3eb..a8ea848 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
[...]
> @@ -274,6 +274,9 @@ enum rtl_register_content {
>  #define RTL8152_MAX_TX		10
>  #define RTL8152_MAX_RX		10
>  #define INTBUFSIZE		2
> +#define CRC_SIZE		4

ETH_FCS_LEN ?

[...]
> @@ -1215,7 +1220,7 @@ static void rx_bottom(struct r8152 *tp)
>  
>  			stats = rtl8152_get_stats(netdev);
>  
> -			pkt_len -= 4; /* CRC */
> +			pkt_len -= CRC_SIZE; /* CRC */
>  			rx_data += sizeof(struct rx_desc);

Nit: you may remove the trailing "/* CRC */" in the same patch.

-- 
Ueimor
