From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: bcm43xx driver unstable behaviour (and linux wireless is junk
	btw)
Date: Sun, 24 Sep 2006 18:47:35 +1000
Message-ID: <1159087655.5924.28.camel@localhost.localdomain>
References: <1159065798.5924.8.camel@localhost.localdomain>
	 <200609241005.02024.mb@bu3sch.de>
	 <1159085579.5924.25.camel@localhost.localdomain>
	 <200609241043.49772.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bcm43xx-dev@lists.berlios.de,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:15813 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1751797AbWIXIrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2006 04:47:46 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609241043.49772.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-09-24 at 10:43 +0200, Michael Buesch wrote:
> On Sunday 24 September 2006 10:12, Benjamin Herrenschmidt wrote:
> > > > So what are the chances of getting this dscape stack merged, let's
> > > > say... for 2.6.19 ? Or we'll get yet another full release with barely
> > > > working wireless ?
> > > 
> > > I don't think it's possible to happen for 2.6.19.
> > > Ealiest 2.6.20 but likely one or two releases later (me thinks).
> > 
> > Which means we'll still have nothing near decent wireless for what ... 6
> > monthes min ?
> 
> Well. Works For Me (tm).
> If there is some bug for you in current mainline, it needs to
> be fixed. But I can't fix something I am not able to reproduce and
> don't know what happens.

Well, there is definitely an issue with softmac going nuts, possibly
related to the chip stopping to transmit, I'm not certain at this point.
It -seems- to be better with Larry's latest patch (the big one) so we'll
see. Then, there is a problem when that happens an d your rmmod,
something kicks in after the driver is gone and crashes the kernel... If
I ever get into the situation where I suspect the rmmod will trigger
that again, I'll try to get into a text VT first so I can capture an
oops...

Ben.
 

