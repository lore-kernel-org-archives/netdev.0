From: David Miller <davem@davemloft.net>
Subject: Re: Yet more fixes to etherh.c
Date: Sun, 22 Feb 2009 02:39:33 -0800 (PST)
Message-ID: <20090222.023933.207642182.davem@davemloft.net>
References: <20090222081947.GF16596@n2100.arm.linux.org.uk>
	<20090222.002414.146849186.davem@davemloft.net>
	<20090222084558.GH16596@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35310
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753361AbZBVKjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 05:39:51 -0500
In-Reply-To: <20090222084558.GH16596@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sun, 22 Feb 2009 08:45:58 +0000

> On Sun, Feb 22, 2009 at 12:24:14AM -0800, David Miller wrote:
> > From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> > Date: Sun, 22 Feb 2009 08:19:47 +0000
> > 
> > > Hmm, I don't see the problem.  What's currently in mainline is:
> > > 
> > >         .ndo_set_mac_address    = eth_mac_addr,
> > 
> > Which didn't go in via the net-2.6 tree, sigh... :-/
> > 
> > Russell, pick your transport medium, either send ARM network driver
> > fixes via me or straight to Linus.
> > 
> > Not some mixture of both, that's only going to lead to confusion,
> > just like it did here.
> > 
> > I put that "eth_mac_addr" fix into net-next-2.6, and you then sent it
> > straight to Linus.
> 
> Hmm, so someone else submitted the same fix for that regression caused
> by fe96aaa.

That someone else was you:

commit 5376071069ec8a7e6a8112beab16fc24f5139475
 ...
    Merge master.kernel.org:/home/rmk/linux-2.6-arm
    
    * master.kernel.org:/home/rmk/linux-2.6-arm: (22 commits)

which brought in:

commit a71558d0eca1bbb23737f832297926666f9b36db
Author: Russell King <rmk@dyn-67.arm.linux.org.uk>
Date:   Tue Jan 27 22:32:29 2009 +0000

    [ARM] etherh: continue fixing build failure
    
    Further to 483a2b3a3182abcb7fcea986d7ea13e793bb00b1, also fix:
    
    drivers/net/arm/etherh.c:649: error: 'eth_set_mac_addr' undeclared here (not in a function)
    
    Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

This was my entire point.

> Given that the eth_mac_addr change is a regression fix, the question has
> to be asked: why is it queued for the next merge window?

Because I thought the regression only existed in net-next-2.6,
probably due to poor communication from the patch submitter :)

> In any case, I'm more than willing to push this through the ARM tree, but
> at the same time I'm aware that people get upset if they're not copied on
> the patches.  That's why I CC'd you with it.

All you need to do is explicitly tell me where a bug fix goes,
and I can get it into Linus's tree in less than a day.

It's all about communication and not doing things like submitting
changes behind my back after I've explicitly replied with an
email saying "Applied" to your patch.
