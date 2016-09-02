From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/3] smsc95xx: Add register define
Date: Fri, 02 Sep 2016 13:40:01 -0700
Message-ID: <1472848801.22931.7.camel@perches.com>
References: <9235D6609DB808459E95D78E17F2E43D409100A1@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0059.hostedemail.com ([216.40.44.59]:51766 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752847AbcIBUkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 16:40:06 -0400
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D409100A1@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-09-02 at 20:34 +0000, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <woojung.huh@microchip.com>
> 
> Add STRAP_STATUS defines.
[]
> diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
[]
> @@ -144,6 +144,14 @@
>  
>  #define BURST_CAP			(0x38)
>  
> +#define	STRAP_STATUS			(0x3C)
> +#define	STRAP_STATUS_PWR_SEL_		(0x00000020)
> +#define	STRAP_STATUS_AMDIX_EN_		(0x00000010)
> +#define	STRAP_STATUS_PORT_SWAP_		(0x00000008)
> +#define	STRAP_STATUS_EEP_SIZE_		(0x00000004)
> +#define	STRAP_STATUS_RMT_WKP_		(0x00000002)
> +#define	STRAP_STATUS_EEP_DISABLE_	(0x00000001)

Using BIT would be more common.

Ending the #defines with an underscore is just odd
and unappealing.
