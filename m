From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Thu, 17 Mar 2011 08:58:35 +0000
Message-ID: <20110317085835.GC29758@n2100.arm.linux.org.uk>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com> <1300184096-13937-4-git-send-email-jamie@jamieiles.com> <87vczkmy94.fsf@macbook.be.48ers.dk> <AANLkTi=TiRnc0ceosH-P7fN7wKrLZE0MCJHQ30gM_Q9b@mail.gmail.com> <871v26m8tf.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "avictor.za@gmail.com" <avictor.za@gmail.com>,
	Jamie Iles <jamie@jamieiles.com>, plagnioj@jcrosoft.com,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com,
	netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:46951 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab1CQI7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 04:59:07 -0400
Content-Disposition: inline
In-Reply-To: <871v26m8tf.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 09:48:28AM +0100, Peter Korsgaard wrote:
> >>>>> "avictor" == avictor za@gmail com <avictor.za@gmail.com> writes:
> 
> Hi,
> 
>  >> How about at the same time renaming it to something a bit less
>  >> generic like macb_platform_data?
> 
>  avictor> The AT91RM9200 uses the same platform_data structure, but has a
>  avictor> different Ethernet peripheral (ie, not the MACB)
> 
>  avictor> The phy_irq_pin is used in the AT91RM9200 ethernet driver.
>  avictor> (drivers/net/arm/at91_ether.c)
> 
> That should probably be cleaned up as well then. Sharing platform_data
> structures between unrelated drivers seems like quite a mess to me.

Why should every driver have a separate platform data structure?
Is it right to end up with thousands of unique data structures each
specific to a particular driver?  To me, that sounds like a headache
waiting to happen.
