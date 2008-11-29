From: James Le Cuirot <chewi@aura-online.co.uk>
Subject: Re: [Suspend-devel] TAP (and TUN?) devices not working after resume
Date: Sat, 29 Nov 2008 10:18:49 +0000
Message-ID: <20081129101849.277ba756@symphony>
References: <20080714154720.791f6640@symphony>
	<200807141812.45264.rjw@sisk.pl>
	<48894D88.9010104@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	suspend-devel@lists.sourceforge.net,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:54364 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751103AbYK2KS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 05:18:57 -0500
In-Reply-To: <48894D88.9010104@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jul 2008 20:50:32 -0700
Max Krasnyansky <maxk@qualcomm.com> wrote:

> > On Monday, 14 of July 2008, James Le Cuirot wrote:  
> >>
> >> Hi,
> >>
> >> uswsusp works great on my machine except for one thing. I use a TAP
> >> device for QEMU and after resuming from suspend, it doesn't work
> >> anymore until I delete it and recreate it. This is rather annoying
> >> because if I have QEMU open, it means I have to close it before
> >> recreating the interface and then boot Windows up again. I use
> >> OpenVPN to create/delete the interface but I think that's all it
> >> does. The rest is done by the kernel. So I'm guessing something's
> >> up with the TUN/TAP driver or uswsusp itself. I'm using version
> >> 0.8. Sorry if this has already been fixed.  
> 
> I bet it's flow control related. I've fixed a bug in flow control
> handling for persistent devices recently.
> btw Does it still happen with >= 2.6.26 ?
> 
> I'll play with some test code on my laptop and see if I can reproduce
> this issue.
> 
> Max

Sorry about the crazy delay here, I didn't need to use QEMU for ages
and I don't like firing up Windows unless I have too. :D I'm not sure
about 2.6.26 but this appears to be fixed in 2.6.27.

Thanks,
James
