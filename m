From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V3 2/2] Introduce huawei_cdc_ncm driver
Date: Wed, 3 Jul 2013 17:18:53 +0100
Message-ID: <1372868333.1919.3.camel@bwh-desktop.uk.level5networks.com>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
	 <87wqp9xja5.fsf@nemi.mork.no>
	 <alpine.LNX.2.02.1307021855270.19053@eeeadesso>
	 <alpine.LNX.2.02.1307022202570.26010@eeeadesso>
	 <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
	 <alpine.LNX.2.02.1307022210470.26010@eeeadesso>
	 <alpine.LNX.2.02.1307022213380.26010@eeeadesso>
	 <alpine.LNX.2.02.1307030836270.12831@eeeadesso>
	 <alpine.LNX.2.02.1307030908090.13789@eeeadesso>
	 <871u7gvz2z.fsf@nemi.mork.no>
	 <alpine.LNX.2.02.1307031455460.24525@eeeadesso>
	 <51D424D1.2010507@cogentembedded.com>
	 <alpine.LNX.2.02.1307031534180.25440@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14124 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932776Ab3GCQS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 12:18:58 -0400
In-Reply-To: <alpine.LNX.2.02.1307031534180.25440@eeeadesso>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-07-03 at 15:38 +0200, Enrico Mioso wrote:
> This new driver, handles devices that mimic the NCM standard, but using NCM as
> a transport layer to encapsulate other protocols (i.e. AT protocol).
> 
> Signed-off-by: Enrico Mioso <mrkiko.rs@gmail.com>

Add a '---' separator here, between the commit message and the list of
changes that doesn't need to go in the commit message.

> V3:
>   - fixed typo in Kconfig (help text)
>
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 287cc62..33cb175 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -246,6 +246,18 @@ config USB_NET_CDC_NCM
>  	    * ST-Ericsson M343 HSPA Mobile Broadband Modem (reference design)
>  	    * Ericsson F5521gw Mobile Broadband Module
>  
> +config USB_NET_HUAWEI_CDC_NCM
> +	tristate "Huawei-style CDC NCM support"
> +	depends on USB_USBNET
> +	default y
> +	select USB_WDM
> +	select USB_NET_CDC_NCM
[...]

The new config symbol should either depend on USB_NET_CDC_NCM (rather
than selecting it), or have no default setting.  It is not correct to
enable it by default just because USB_USBNET is selected.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
