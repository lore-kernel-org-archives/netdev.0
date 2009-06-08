From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] sit: handle ICMPv4 for tunnels with no remote
Date: Mon, 08 Jun 2009 02:40:24 -0700 (PDT)
Message-ID: <20090608.024024.236334849.davem@davemloft.net>
References: <1244296972-20748-1-git-send-email-contact@saschahlusiak.de>
	<1244296972-20748-2-git-send-email-contact@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: contact@saschahlusiak.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751003AbZFHJkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 05:40:23 -0400
In-Reply-To: <1244296972-20748-2-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hlusiak <contact@saschahlusiak.de>
Date: Sat,  6 Jun 2009 16:02:51 +0200

> Don't drop ICMPv4 packages, if tunnel has no remote endpoint, like
> 6to4 or isatap tunnels.
> 
> Also don't drop it if tunnel inherits ttl and icmp_time_exceeded.
> Don't really see the usecase here.
> 
> Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>

You're going to have to describe this change a bit more.

What in the world is wrong with dropping an ICMP time exceeded if the
TTL in the template header is zero?  Someone wrote that code and had
some reason to put it there.   Until you know the reason or can prove
without a shadow of doubt that it's pointless, you can't just remove
it.

You other two changes need more verbose commit messages as well.
I can't tell what the point or benefit are of your changes.

So I'm dropping your patches until all of this is resolved, and
the commit messages are more verbose and explain why you're doing
all of these things.

