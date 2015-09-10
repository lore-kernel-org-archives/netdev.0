From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/5] lan78xx: Add PHYLIB and MICROCHIP_PHY as default
 config.
Date: Thu, 10 Sep 2015 14:46:57 -0700
Message-ID: <55F1FA51.4000007@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D557C4F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33937 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbbIJVtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 17:49:40 -0400
Received: by padhy16 with SMTP id hy16so54051534pad.1
        for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 14:49:40 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D557C4F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/15 13:48, Woojung.Huh@microchip.com wrote:
> Add PHYLIB and MICROCHIP_PHY as default configuration for  lan78xx.

You would want to swap this patch and patch 2 to make sure that there is
no user-visible breakage in between.

> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  drivers/net/usb/Kconfig | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 1610b79..d9ca7aa 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -109,6 +109,8 @@ config USB_RTL8152
>  config USB_LAN78XX
>  	tristate "Microchip LAN78XX Based USB Ethernet Adapters"
>  	select MII
> +	select PHYLIB
> +	select MICROCHIP_PHY
>  	help
>  	  This option adds support for Microchip LAN78XX based USB 2
>  	  & USB 3 10/100/1000 Ethernet adapters.
> 


-- 
Florian
