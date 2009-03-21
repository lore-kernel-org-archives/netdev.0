From: David Miller <davem@davemloft.net>
Subject: Re: e1000 under VMware doesn't work since 2.6.27.16 - BISECTED
Date: Fri, 20 Mar 2009 17:00:07 -0700 (PDT)
Message-ID: <20090320.170007.204645866.davem@davemloft.net>
References: <20090320.155739.93629479.davem@davemloft.net>
	<adafxh7yext.fsf@cisco.com>
	<20090320.165516.112348262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drifter@bcsoft.de, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47834
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751116AbZCUAAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 20:00:20 -0400
In-Reply-To: <20090320.165516.112348262.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 20 Mar 2009 16:55:16 -0700 (PDT)

> From: Roland Dreier <rdreier@cisco.com>
> Date: Fri, 20 Mar 2009 16:03:58 -0700
> 
> >  > > we're using virtual machines under VMware with the e1000 emulated
> >  > > network card.
> > 
> >  > Sounds like vmware doesn't emulate the e1000 accurately enough.
> > 
> > I would consider problems with the vmware emulated e1000 to be similar
> > to hardware quirks in some other chip rev supported by the e1000
> > driver.  If a driver change broke e1000 inside a vmware VM then we
> > should probably fix the kernel if possible (although vmware probably
> > wants to improve their emulation too).
> 
> If such a "fix" would be to the detriment of real actual hardware,
> this logic doesn't hold.
> 
> The same applies to cases like qemu as well.

And I want to amend this to state that I emphatically do not think
that a driver maintainer is on the hook to be compatible with
all the software emulators out there.

That's rediculious.

Keeping up with the problems on real hardware is difficult enough.  At
the very least the software emulators can be fixed easily, whereas
real hardware not so much.
