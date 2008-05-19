From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 19 May 2008 20:06:58 +0100
Message-ID: <OFC4CFDC61.35AD3CC6-ON8025744E.00672B06-8025744E.006901EC@smsc.com>
References: <1211214246.24946.47.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org, Ian.Saturley@smsc.com
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2520 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761835AbYESTH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 15:07:26 -0400
In-Reply-To: <1211214246.24946.47.camel@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Catalin,

> > --- /dev/null
> > +++ b/drivers/net/smsc911x.h
> [...]
> > +/* platform_device configuration data, should be assigned to
> > + * the platform_device's dev.platform_data */
> > +struct smsc911x_platform_config {
> > +   unsigned int irq_polarity;
> > +   unsigned int irq_type;
> > +};
> 
> BTW, how could this structure be used in the platform specific code
> (arch/arm/mach-*/* in my case)? This header file cannot be included
> since it is not under the include/ directory and redefining the
> structure for each platform is prone to errors (and too much
> duplication). I can see other drivers place a header file (maybe only
> containing the structure definition) in include/linux/ or include/asm-*/
> (the latter if it is specific to only one architecture which I don't
> think it is the case here). 

Thanks Catalin, I meant to ask if this the right thing to do.

I'll keep the device register definitions in the same place and move
struct smsc911x_platform_config to a new file in include/linux/.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com
