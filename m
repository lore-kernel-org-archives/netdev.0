From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 14/16] RealView: Use the in-kernel smc911x.c driver on	RealView
Date: Tue, 21 Oct 2008 20:32:50 +0100
Message-ID: <OF1496E847.AC9DA8EC-ON802574E9.0069AD9D-802574E9.006B6C54@smsc.com>
References: <20081021184653.GA15027@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bill Gatliff <bgat@billgatliff.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	Ian.Saturley@smsc.com, linux-arm-kernel@lists.arm.linux.org.uk,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3620 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751056AbYJUTdx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 15:33:53 -0400
In-Reply-To: <20081021184653.GA15027@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Russell King - ARM Linux <linux@arm.linux.org.uk> wrote on 21/10/2008 
19:46:53:

> On Tue, Oct 21, 2008 at 11:26:42AM +0100, Steve.Glendinning@smsc.com 
wrote:
> > Almost all the feedback I've had has been positive, but I've had a few
> > "can't you just fix the in-tree driver?" responses.  The trouble is 
it's
> > not a *small* piece of work!
> 
> Which is reasonable given your summary, since...
> 
> > smsc911x
> > - uses functions instead of macros, making it more readable
> > - uses napi (and manages significantly higher throughput because of 
it)
> > - uses phylib
> > - passes checkpatch.pl
> > - has workarounds for older LAN911x variants
> > 
> > smc911x
> > - is already in-tree (not really technical, but still important)
> > - has support for pxa dma*
> > - has dynamic bus width config
>
> .. we want to avoid having two drivers for the same device, but not
> supporting these features would be seen as a regression.

Exactly, we already have two drivers.  Only one is currently in-tree, but
both have users.  The question is where we go from here?

I believe it's much easier to bring smsc911x up to feature parity with
smc911x than vice-versa.  The dynamic bus configuration is simple enough
to add, and Bill Gatliff has offered to help out with PXA DMA support.
I'd like us to reach a consensus first though, so we all know the plan
moving forward!

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com




