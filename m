From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/1] alx driver
Date: Wed, 12 Jun 2013 20:00:35 +0200
Message-ID: <1371060035.8601.30.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <20130612071107.GA7765@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:42789 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757697Ab3FLSAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 14:00:46 -0400
In-Reply-To: <20130612071107.GA7765@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-12 at 09:11 +0200, Johannes Stezenbach wrote:
> On Mon, Jun 10, 2013 at 11:26:48PM +0200, Johannes Berg wrote:
> > So ... I was stupid enough to not research drivers for this device
> > before buying a board that included one, I figured in 2013 it wasn't
> > really possible for such a simple gigabit ethernet device to not
> > have a driver in Linux.
> > 
> > Boy was I wrong.
> > 
> > The vendor driver was previously posted on netdev, and subsequently
> > somewhat cleaned up, but ... it still had useless hand-rolled locks
> > (with test_and_set_bit/msleep!), horrible macros, and was generally
> > quite a mess.
> 
> I had the same unpleasant experience about missing alx driver
> for my Asus P8H77-V board.  I found this:
> http://www.linuxfoundation.org/collaborate/workgroups/networking/alx
> https://github.com/qca/alx
> 
> And this mail talks about upstreaming:
> http://lists.infradead.org/pipermail/unified-drivers/2013-April/000064.html

There as been lots of talk, and they even submitted a driver once, but
it was pretty crappy ... I decided that cleaning it up now, while
liberally and deliberately removing features I don't want to worry about
right now, was going to be easier than using their out of tree driver
for my system forever, because I have little hope that they'll actually
manage to put something upstreamable together.

Anyway, it's a completely spare-time effort for me, so contributions to
the driver are clearly welcome.

johannes
