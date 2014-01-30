From: Paul Zimmerman <paulz@synopsys.com>
Subject: RE: Help testing for USB ethernet/xHCI regression
Date: Thu, 30 Jan 2014 19:54:30 +0000
Message-ID: <A2CA0424C0A6F04399FB9E1CD98E03046D147453@US01WEMBX2.internal.synopsys.com>
References: <22081260.RNay0J72dY@athas> <20140129215408.GC5991@xanatos>
 <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20@AcuExch.aculab.com>
 <20140130184412.GA3787@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "renevant@internode.on.net" <renevant@internode.on.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Mark Lord <mlord@pobox.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.44.111]:54181 "EHLO
	smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbaA3UA3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 15:00:29 -0500
In-Reply-To: <20140130184412.GA3787@xanatos>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: linux-usb-owner@vger.kernel.org [mailto:linux-usb-owner@vger.kernel.org] On Behalf Of Sarah Sharp
> Sent: Thursday, January 30, 2014 10:44 AM
> To: David Laight
> Cc: renevant@internode.on.net; linux-usb@vger.kernel.org; Mark Lord; Greg Kroah-Hartman;
> netdev@vger.kernel.org
> Subject: Re: Help testing for USB ethernet/xHCI regression
> 
> On Thu, Jan 30, 2014 at 09:44:53AM +0000, David Laight wrote:
> > From: Sarah Sharp
> > > > Current issue is when plugging in the ax88179 there is lag when bringing the
> > > > interface up and a bunch of kernel messages:
> 
> > > > [   79.481028] IPv6: ADDRCONF(NETDEV_UP): enp7s0u1: link is not ready
> > > > [   82.210721] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > > [   82.338947] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > > [   82.467148] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> > > > [   82.470028] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > > [   82.595364] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> > > > [   82.598312] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > > [   82.723580] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> > > > [   82.726487] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> > > > [   82.851796] ax88179_178a 2-1:1.0 enp7s0u1: kevent 4 may have been dropped
> > > > [   82.854642] ax88179_178a 2-1:1.0 enp7s0u1: ax88179 - Link status is: 1
> 
> > >
> > > With which kernel?
> >
> > I saw similar issues testing some patches yesterday.
> > Both with the ax179_178a and smsx95xx cards (connected to xhci).
> > My kernel claims to be 3.13.0-dsl+ but it is lying since it was
> > updated from linus's tree earlier this week.
> > I'd not seen any similar delays until the last week or so.
> 
> I see a report that these types of errors have been seen since the 3.11
> kernel:
> 
> http://marc.info/?l=linux-usb&m=139105963723745&w=2
> 
> Since the USB ethernet scatter-gather support wasn't added until the
> 3.12 kernel, it's unlikely that the xHCI TD fragment issue is actually
> the root cause.
> 
> The interesting piece of information in that report is that when the USB
> 3.0 device falls back to USB 2.0 speeds under xHCI, it works.
> 
> > The xhci controller I'm using is the Intel 'Panther Point' 8086:1e31
> > rev 4 (also says 8086:1e2d and 8086:1e26).
> 
> That's the host I have as well.  I've been able to find an ASIX device
> with the right chipset, so I'm going to poke around at what's happening
> at the USB 3.0 bus level.

Hi Sarah,

Can you give a pointer to where we could buy one of these devices? I
would like to test this with our (Synopsys) xHCI controller as well.

-- 
Paul
