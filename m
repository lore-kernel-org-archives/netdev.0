From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Yet more fixes to etherh.c
Date: Sun, 22 Feb 2009 11:46:01 +0000
Message-ID: <20090222114601.GD28025@n2100.arm.linux.org.uk>
References: <20090222081947.GF16596@n2100.arm.linux.org.uk> <20090222.002414.146849186.davem@davemloft.net> <20090222084558.GH16596@n2100.arm.linux.org.uk> <20090222.023933.207642182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:47624 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbZBVLqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Feb 2009 06:46:16 -0500
Content-Disposition: inline
In-Reply-To: <20090222.023933.207642182.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 22, 2009 at 02:39:33AM -0800, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Sun, 22 Feb 2009 08:45:58 +0000
> 
> > On Sun, Feb 22, 2009 at 12:24:14AM -0800, David Miller wrote:
> > > From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> > > Date: Sun, 22 Feb 2009 08:19:47 +0000
> > > 
> > > > Hmm, I don't see the problem.  What's currently in mainline is:
> > > > 
> > > >         .ndo_set_mac_address    = eth_mac_addr,
> > > 
> > > Which didn't go in via the net-2.6 tree, sigh... :-/
> > > 
> > > Russell, pick your transport medium, either send ARM network driver
> > > fixes via me or straight to Linus.
> > > 
> > > Not some mixture of both, that's only going to lead to confusion,
> > > just like it did here.
> > > 
> > > I put that "eth_mac_addr" fix into net-next-2.6, and you then sent it
> > > straight to Linus.
> > 
> > Hmm, so someone else submitted the same fix for that regression caused
> > by fe96aaa.
> 
> That someone else was you:
> 
> commit 5376071069ec8a7e6a8112beab16fc24f5139475
>  ...
>     Merge master.kernel.org:/home/rmk/linux-2.6-arm
>     
>     * master.kernel.org:/home/rmk/linux-2.6-arm: (22 commits)
> 
> which brought in:
> 
> commit a71558d0eca1bbb23737f832297926666f9b36db
> Author: Russell King <rmk@dyn-67.arm.linux.org.uk>
> Date:   Tue Jan 27 22:32:29 2009 +0000
> 
>     [ARM] etherh: continue fixing build failure
>     
>     Further to 483a2b3a3182abcb7fcea986d7ea13e793bb00b1, also fix:
>     
>     drivers/net/arm/etherh.c:649: error: 'eth_set_mac_addr' undeclared here (not in a function)
>     
>     Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> This was my entire point.

Yes, I know I put that into mainline via my tree...

> > Given that the eth_mac_addr change is a regression fix, the question has
> > to be asked: why is it queued for the next merge window?
> 
> Because I thought the regression only existed in net-next-2.6,
> probably due to poor communication from the patch submitter :)
> 
> > In any case, I'm more than willing to push this through the ARM tree, but
> > at the same time I'm aware that people get upset if they're not copied on
> > the patches.  That's why I CC'd you with it.
> 
> All you need to do is explicitly tell me where a bug fix goes,
> and I can get it into Linus's tree in less than a day.
> 
> It's all about communication and not doing things like submitting
> changes behind my back after I've explicitly replied with an
> email saying "Applied" to your patch.

... but I must have forgotten that I'd already sent it to you.  I don't
seem to have a record of sending it.

What I do have is that I raised the issue of the ndo_set_mac_addr in
January on netdev.  To that I got a reply from Stephen about it, to
which I asked whether he wanted me to fix it via my tree.  The response
I got in private was "yes" (and I won't reveal the rest of it because
it refers to his travel around that time.)

In reply to that I sent Stephen a patch, which being a reply to a private
message couldn't be CC'd back to netdev.

However, coincidentally, it seems that you fixed the precise error I
raised (thanks) but missed the eth_set_mac_addr mis-spelling, so I dropped
my original patch.  I didn't get any further response from on the issue,
so I'd assumed two weeks later that it was dead and fixed the remaining
issue.

So, as far as I can see, I never sent you a patch for to fix the
eth_set_mac_addr -> eth_mac_addr change.  If you have that in your
tree, someone else must have sent it to you (maybe Stephen forwarded
it?)
