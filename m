From: "stanley.miao" <stanley.miao@windriver.com>
Subject: Re: [PATCHv2] smsc911x: add irq_flags in smsc911x_platform_config.
Date: Wed, 14 Jan 2009 18:22:50 +0800
Message-ID: <1231928570.6810.12.camel@localhost>
References: <1231916280-7391-1-git-send-email-stanley.miao@windriver.com>
	 <OF8C316D93.937F4899-ON8025753E.0030604F-8025753E.003106B3@smsc.com>
	 <20090114100550.GA22976@n2100.arm.linux.org.uk>
Reply-To: stanley.miao@windriver.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Steve.Glendinning@smsc.com, David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61871 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706AbZANKOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 05:14:38 -0500
In-Reply-To: <20090114100550.GA22976@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-01-14 at 10:05 +0000, Russell King - ARM Linux wrote:
> On Wed, Jan 14, 2009 at 08:54:36AM +0000, Steve.Glendinning@smsc.com wrote:
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
> > irq_flags change, as they register their interrupts shared.  David: would 
> > it make sense to put this driver patch into the arm tree?
> 
> Does this really make sense?  Normally, the interrupt level/edge stuff is
> passed through the resource structure.
> 
> I can't really comment because it seems that there's no way to work out
> what patch you're acking.  I can't find it in the last 6 months of email,
> and there's no attributation for your quoted reply to hint at when the
> original message was sent.

Hi, Russell,

Did you subscribe netdev mail list ? Maybe it was filtered into netdev
mail list. I just send the patch 4 hours ago.

Stanley.
