From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: convert mvneta to build_skb()
Date: Mon, 15 Jul 2013 17:35:23 +0200
Message-ID: <20130715173523.4505e8c4@skate>
References: <20130704173552.GA23370@1wt.eu>
	<20130715163408.4064699f@skate>
	<20130715151240.GD6844@1wt.eu>
	<20130715172321.61e8c237@skate>
	<20130715153049.GE6844@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:58260 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932535Ab3GOPgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 11:36:52 -0400
In-Reply-To: <20130715153049.GE6844@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Willy Tarreau,

On Mon, 15 Jul 2013 17:30:49 +0200, Willy Tarreau wrote:

> On Mon, Jul 15, 2013 at 05:23:21PM +0200, Thomas Petazzoni wrote:
> > The big-endian support is pretty light in terms of driver changes, so
> > if there are conflicts, they should be easy to solve.
> 
> I agree.
> 
> BTW, I'm still having the patch to re-enable phy-polling at boot in my
> queue. Last time I tried without it I still only had eth0 working. I
> completely forgot about this one. Since I did it blindly, I have no way
> to verify if what I've done is necessary according to the specs. But I'm
> quite sure that the NICs that are not enabled by the boot loaders don't
> work.
> 
> If you want, I'll resend it to you at the same time.

I still believe this is not the right fix, but unfortunately, I haven't
had the time to work on what would be the right fix. Hardware PHY
polling has been intentionally disabled, and the driver should work
without, since the PHY polling is done in software by the phylib.

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
