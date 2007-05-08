From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] libertas: fix for wireless Kconfig changes
Date: Tue, 08 May 2007 01:20:36 -0400
Message-ID: <464008A4.4020501@garzik.org>
References: <20070429002844.GA11225@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54413 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967940AbXEHFUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:20:40 -0400
In-Reply-To: <20070429002844.GA11225@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Need to change the libertas Kconfig entry to match changes made for
> other wireless drivers.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
> index c4b3dc2..cb09e6b 100644
> --- a/drivers/net/wireless/Kconfig
> +++ b/drivers/net/wireless/Kconfig
> @@ -267,7 +267,7 @@ config IPW2200_DEBUG
>  
>  config LIBERTAS_USB
>  	tristate "Marvell Libertas 8388 802.11a/b/g cards"
> -	depends on NET_RADIO && USB
> +	depends on USB && WLAN_80211

applied


