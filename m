From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 1/2] Add SMC_MEM_RESERVED for OMAP platform.
Date: Mon, 17 Nov 2008 10:31:03 +0000
Message-ID: <OF1AFB43DD.9BED76B1-ON80257504.00386A7C-80257504.0039CC57@smsc.com>
References: <1226914195-20473-1-git-send-email-stanley.miao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: "Stanley.Miao" <stanley.miao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3273 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752270AbYKQKbg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 05:31:36 -0500
In-Reply-To: <1226914195-20473-1-git-send-email-stanley.miao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stanley,

Jeff has merged the smsc911x driver into -next, this is intended to 
replace smc911x moving forward.  I'll forward the patchset to you 
off-list, it includes platform_data support for several platforms so 
adding support for omap should be simple.

> diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
> index cc7d85b..d1b3b9b 100644
> --- a/drivers/net/smc911x.h
> +++ b/drivers/net/smc911x.h
> @@ -42,6 +42,16 @@
>    #define SMC_USE_16BIT      0
>    #define SMC_USE_32BIT      1
>    #define SMC_IRQ_SENSE      IRQF_TRIGGER_LOW
> +#elif defined(CONFIG_ARCH_OMAP34XX)
> +  #define SMC_USE_16BIT      0
> +  #define SMC_USE_32BIT      1
> +  #define SMC_IRQ_SENSE      IRQF_TRIGGER_LOW
> +  #define SMC_MEM_RESERVED   1
> +#elif defined(CONFIG_ARCH_OMAP24XX)
> +  #define SMC_USE_16BIT      0
> +  #define SMC_USE_32BIT      1
> +  #define SMC_IRQ_SENSE      IRQF_TRIGGER_LOW
> +  #define SMC_MEM_RESERVED   1
>  #else
>  /*
>   * Default configuration

nack - this platform-specific configuration shouldn't be in the driver, 
SMC_DYNAMIC_BUS_CONFIG was added so this can be specified in 
platform_data.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com

