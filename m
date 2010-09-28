From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] de2104x: remove experimental status
Date: Tue, 28 Sep 2010 14:52:19 -0400
Message-ID: <4CA23963.8040409@pobox.com>
References: <201009282046.21279.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:60890 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756857Ab0I1SwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 14:52:23 -0400
In-Reply-To: <201009282046.21279.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2010 02:46 PM, Ondrej Zary wrote:
> It should be ready after 8 years...remove the experimental dependency.
>
> Signed-off-by: Ondrej Zary<linux@rainbow-software.org>
>
> --- linux-2.6.36-rc3-/drivers/net/tulip/Kconfig	2010-08-29 17:36:04.000000000 +0200
> +++ linux-2.6.36-rc3/drivers/net/tulip/Kconfig	2010-09-28 19:49:46.000000000 +0200
> @@ -11,8 +11,8 @@ menuconfig NET_TULIP
>   if NET_TULIP
>
>   config DE2104X
> -	tristate "Early DECchip Tulip (dc2104x) PCI support (EXPERIMENTAL)"
> -	depends on PCI&&  EXPERIMENTAL
> +	tristate "Early DECchip Tulip (dc2104x) PCI support"
> +	depends on PCI
>   	select CRC32
>   	---help---
>   	  This driver is developed for the SMC EtherPower series Ethernet

Well...  it's not the years, it's the quality...  which I think has been 
sufficiently increased.

Acked-by: Jeff Garzik <jgarzik@redhat.com>


