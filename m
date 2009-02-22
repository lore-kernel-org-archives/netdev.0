From: David Miller <davem@davemloft.net>
Subject: Re: Yet more fixes to etherh.c
Date: Sun, 22 Feb 2009 00:24:14 -0800 (PST)
Message-ID: <20090222.002414.146849186.davem@davemloft.net>
References: <20090221193633.GD16596@n2100.arm.linux.org.uk>
	<20090221.234448.26454123.davem@davemloft.net>
	<20090222081947.GF16596@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59361
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751283AbZBVIYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 03:24:33 -0500
In-Reply-To: <20090222081947.GF16596@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sun, 22 Feb 2009 08:19:47 +0000

> On Sat, Feb 21, 2009 at 11:44:48PM -0800, David Miller wrote:
> > From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> > Date: Sat, 21 Feb 2009 19:36:33 +0000
> > 
> > > Further to a71558d, this is round five of fixes to make etherh work
> > > again. As mainline kernels stand, the fixes in b9a9b4b were the wrong
> > > approach.
> >  ...
> > > Fix up b9a9b4b by making etherh's net_device_ops refer to the internal
> > > lib8390 functions, and remove the build of the ISA 8390.c driver.
> > > 
> > > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> > 
> > Applied to net-next-2.6, thanks Russell.
> > 
> > You mention this as a fix against mainline, but your patch
> > only applied to net-next-2.6 because the "eth_set_mac_addr"
> > fix to this driver only exists there.
> 
> Hmm, I don't see the problem.  What's currently in mainline is:
> 
>         .ndo_set_mac_address    = eth_mac_addr,

Which didn't go in via the net-2.6 tree, sigh... :-/

Russell, pick your transport medium, either send ARM network driver
fixes via me or straight to Linus.

Not some mixture of both, that's only going to lead to confusion,
just like it did here.

I put that "eth_mac_addr" fix into net-next-2.6, and you then sent it
straight to Linus.
