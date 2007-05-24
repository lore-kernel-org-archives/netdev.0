From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Add select PHYLIB to the UCC_GETH Kconfig option
Date: Thu, 24 May 2007 17:47:59 -0400
Message-ID: <4656080F.4080006@garzik.org>
References: <1179926613.3839.47.camel@bender>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kim.phillips@freescale.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jan Altenberg <jan.altenberg@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48384 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144AbXEXVsG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:48:06 -0400
In-Reply-To: <1179926613.3839.47.camel@bender>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Altenberg wrote:
> ucc_geth has been migrated to use the common phylib code. So lets add a
> 'select PHYLIB' to the UCC_GETH Kconfig entry.
> 
> Signed-off-by: Jan Altenberg <jan.altenberg@linutronix.de>
> 
> ---
>  drivers/net/Kconfig |    1 +
>  1 file changed, 1 insertion(+)
> 
> Index: linux-2.6/drivers/net/Kconfig
> ===================================================================
> --- linux-2.6.orig/drivers/net/Kconfig
> +++ linux-2.6/drivers/net/Kconfig
> @@ -2280,6 +2280,7 @@ config GFAR_NAPI
>  config UCC_GETH
>  	tristate "Freescale QE Gigabit Ethernet"
>  	depends on QUICC_ENGINE
> +	select PHYLIB
>  	select UCC_FAST

Please fix the Kconfig warnings first.

Also, I ask again:  WHO IS THE MAINTAINER OF THIS DRIVER?

I am tired of five independent people patching the same driver.

	Jeff



