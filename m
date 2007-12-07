From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch resend build-breakage] make bnx2x select ZLIB_INFLATE
Date: Fri, 07 Dec 2007 15:03:07 -0500
Message-ID: <4759A6FB.2090607@garzik.org>
References: <1196863959.5204.25.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Lee Schermerhorn <Lee.Schermerhorn@hp.com>
To: Eliezer Tamir <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40142 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757715AbXLGUDO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 15:03:14 -0500
In-Reply-To: <1196863959.5204.25.camel@lb-tlvb-eliezer.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eliezer Tamir wrote:
> The bnx2x module depends on the zlib_inflate functions.  The
> build will fail if ZLIB_INFLATE has not been selected manually
> or by building another module that automatically selects it.
> 
> Modify BNX2X config option to 'select ZLIB_INFLATE' like BNX2
> and others.  This seems to fix it.
> 
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> Acked-by: Eliezer Tamir <eliezert@broadcom.com>
> ---
>  drivers/net/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 5bafb30..b9d7f5b 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2594,6 +2594,7 @@ config TEHUTI
>  config BNX2X
>  	tristate "Broadcom NetXtremeII 10Gb support"
>  	depends on PCI
> +	select ZLIB_INFLATE
>  	help

applied #upstream-fixes


