From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH REPOST 0/5] convert arm platforms to smsc911x
Date: Mon, 19 Jan 2009 09:53:54 +0000
Message-ID: <OF8A57C3FE.48B3489D-ON80257543.0035BD44-80257543.003675E0@smsc.com>
References: <20090119092257.GB13737@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, ian.saturley@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	"stanley.miao" <stanley.miao@windriver.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:4942 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759885AbZASJzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 04:55:41 -0500
In-Reply-To: <20090119092257.GB13737@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux <linux@arm.linux.org.uk> wrote on 19/01/2009 
09:22:57:
> On Mon, Jan 19, 2009 at 04:04:34PM +0800, stanley.miao wrote:
> > On Sun, 2009-01-18 at 21:53 -0800, David Miller wrote:
> > > I've applied patches 1 and 2, the smsc911x driver changes.
> > > 
> > > I can pull the platform changes into net-next-2.6 as well
> > > if people don't think there will enough conflicts to cause
> > > problems.
> > 
> > I think  the platform data had better stay in arm tree.
> 
> What would be the impact if patches 3 to 5 got merged before 1 and 2?

It would not break compilation, but it would probably break ethernet 
support
on those three platforms.

All 3 platforms pass some combination of IRQF_TRIGGER_LOW | IRQF_SHARED 
when
registering these interrupts.  The trigger flag isn't passed through 
without
1 and IRQF_SHARED isn't specified without 2.

I expect register_irq would fail on these platforms without these flags?

Steve
