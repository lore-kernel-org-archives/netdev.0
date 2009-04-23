From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] smsc911x: add fifo byteswap support
Date: Thu, 23 Apr 2009 12:33:33 +0100
Message-ID: <OF0BDED475.580A7BDC-ON802575A1.003F11AE-802575A1.003F7D39@smsc.com>
References: <20090423020925.GA8818@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, Ian.Saturley@smsc.com, iwamatsu@nigauri.org,
	Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org
To: Paul Mundt <lethal@linux-sh.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3989 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753037AbZDWLdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2009 07:33:45 -0400
In-Reply-To: <20090423020925.GA8818@linux-sh.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Mundt <lethal@linux-sh.org> wrote on 23/04/2009 03:09:25:

> > The best solution would be to swap the byte lanes in hardware,
> > as the device's endian swapping features only affect registers
> > (not the FIFOs).  The very latest devices in this family
> > (such as the LAN9221) can swap both independently, but this
> > driver has to also support older parts.
> > 
> > Performance will be suboptimal with this software byteswapping,
> > so I think we should also add a comment to stress that this is
> > a "last resort" workaround for broken hardware.
> > 
> > Acked-by: Steve Glendinning <steve.glendinning@smsc.com>
> 
> Performance is not much of a consideration here, it's basically between
> this and no ethernet at all. On the plus side, at least not many boards
> will need this, I believe it's only 2 generations of microcontroller
> evaluation boards that suffer from this particular bit of idiocy on our
> side.

I agree, it's a handy feature to have when you're stuck with broken
hardware.  I'd like everyone who enables it to KNOW that their hardware
is broken however, so hopefully they push back on their hardware guys
to correct it in a later revision.

I'd like to avoid people getting a broken platform working using this,
then later complaining about performance!

Steve
