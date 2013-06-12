From: Johannes Stezenbach <js@sig21.net>
Subject: Re: [PATCH 0/1] alx driver
Date: Wed, 12 Jun 2013 09:11:07 +0200
Message-ID: <20130612071107.GA7765@sig21.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bar.sig21.net ([80.81.252.164]:39153 "EHLO bar.sig21.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752567Ab3FLHjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 03:39:44 -0400
Content-Disposition: inline
In-Reply-To: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 10, 2013 at 11:26:48PM +0200, Johannes Berg wrote:
> So ... I was stupid enough to not research drivers for this device
> before buying a board that included one, I figured in 2013 it wasn't
> really possible for such a simple gigabit ethernet device to not
> have a driver in Linux.
> 
> Boy was I wrong.
> 
> The vendor driver was previously posted on netdev, and subsequently
> somewhat cleaned up, but ... it still had useless hand-rolled locks
> (with test_and_set_bit/msleep!), horrible macros, and was generally
> quite a mess.

I had the same unpleasant experience about missing alx driver
for my Asus P8H77-V board.  I found this:
http://www.linuxfoundation.org/collaborate/workgroups/networking/alx
https://github.com/qca/alx

And this mail talks about upstreaming:
http://lists.infradead.org/pipermail/unified-drivers/2013-April/000064.html


Johannes
