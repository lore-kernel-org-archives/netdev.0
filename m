From: "stanley.miao" <stanley.miao@windriver.com>
Subject: Re: [PATCH 1/2] Add SMC_MEM_RESERVED for OMAP platform.
Date: Tue, 18 Nov 2008 09:37:41 +0800
Message-ID: <1226972261.14497.4.camel@localhost>
References: <OF1AFB43DD.9BED76B1-ON80257504.00386A7C-80257504.0039CC57@smsc.com>
Reply-To: stanley.miao@windriver.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53423 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751867AbYKRBbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 20:31:35 -0500
In-Reply-To: <OF1AFB43DD.9BED76B1-ON80257504.00386A7C-80257504.0039CC57@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-17 at 10:31 +0000, Steve.Glendinning@smsc.com wrote:
> Hi Stanley,
> 
> Jeff has merged the smsc911x driver into -next, this is intended to 
> replace smc911x moving forward.  I'll forward the patchset to you 
> off-list, it includes platform_data support for several platforms so 
> adding support for omap should be simple.

OK, Thanks.

Stanley.

> 
> > diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
> > index cc7d85b..d1b3b9b 100644
> > --- a/drivers/net/smc911x.h
> > +++ b/drivers/net/smc911x.h
> > @@ -42,6 +42,16 @@
> >    #define SMC_USE_16BIT      0
> >    #define SMC_USE_32BIT      1
> >    #define SMC_IRQ_SENSE      IRQF_TRIGGER_LOW
> > +#elif defined(CONFIG_ARCH_OMAP34XX)
> > +  #define SMC_USE_16BIT      0
> > +  #define SMC_USE_32BIT      1
> > +  #define SMC_IRQ_SENSE      IRQF_TRIGGER_LOW
> > +  #define SMC_MEM_RESERVED   1
> > +#elif defined(CONFIG_ARCH_OMAP24XX)
> > +  #define SMC_USE_16BIT      0
> > +  #define SMC_USE_32BIT      1
> > +  #define SMC_IRQ_SENSE      IRQF_TRIGGER_LOW
> > +  #define SMC_MEM_RESERVED   1
> >  #else
> >  /*
> >   * Default configuration
> 
> nack - this platform-specific configuration shouldn't be in the driver, 
> SMC_DYNAMIC_BUS_CONFIG was added so this can be specified in 
> platform_data.
> 
> Regards,
> --
> Steve Glendinning
> SMSC GmbH
> m: +44 777 933 9124
> e: steve.glendinning@smsc.com
> 
