From: Steve.Glendinning@smsc.com
Subject: Re: [PATCHv2] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Wed, 14 Jan 2009 10:11:02 +0000
Message-ID: <OF9A85B122.E6DAE1D8-ON8025753E.0037EC86-8025753E.00380622@smsc.com>
References: <20090114100550.GA22976@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	"Stanley.Miao" <stanley.miao@windriver.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3628 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752805AbZANKMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 05:12:37 -0500
In-Reply-To: <20090114100550.GA22976@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

> > > When calling request IRQ it is desirable to allow platforms
> > > to specific flags for the call to request_irq. Adding irq_flags
> > > to smsc911x_platform_config allows these flags to be passed.
> > > 
> > > Signed-off-by: Stanley.Miao <stanley.miao@windriver.com>
> > 
> > Acked-by: Steve Glendinning <steve.glendinning@smsc.com>
> > 
> > Thanks Stanley.
> > 
> > I have two more arm platform smsc911x conversion patches (realview and 

> > pcm037) which I'll post for review shortly.  Both also depend on this 
> > irq_flags change, as they register their interrupts shared.  David: 
would 
> > it make sense to put this driver patch into the arm tree?
> 
> Does this really make sense?  Normally, the interrupt level/edge stuff 
is
> passed through the resource structure.
> 
> I can't really comment because it seems that there's no way to work out
> what patch you're acking.  I can't find it in the last 6 months of 
email,
> and there's no attributation for your quoted reply to hint at when the
> original message was sent.

Here's the patch:  http://patchwork.ozlabs.org/patch/18386/

Steve
