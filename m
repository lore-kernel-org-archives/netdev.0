From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Fix incorrect disable_ipv6 behavior
Date: Fri, 13 Mar 2009 19:24:48 -0700 (PDT)
Message-ID: <20090313.192448.155806143.davem@davemloft.net>
References: <1236292120-32050-1-git-send-email-brian.haley@hp.com>
	<49BAFFD8.7030705@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53029
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750886AbZCNCZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 22:25:03 -0400
In-Reply-To: <49BAFFD8.7030705@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 13 Mar 2009 20:52:40 -0400

> Brian Haley wrote:
> > Fix the behavior of allowing both sysctl and addrconf_dad_failure()
> > to set the disable_ipv6 parameter without any bad side-effects.
> > If DAD fails and accept_dad > 1, we will still set disable_ipv6=1,
> > but then instead of allowing an RA to add an address then
> > immediately fail DAD, we simply don't allow the address to be
> > added in the first place.  This also lets the user set this flag
> > and disable all IPv6 addresses on the interface, or on the entire
> > system.
> 
> So I haven't seen an Ack/Nack for this patch, and the patchwork queue has shrunk
> to just a handful in the past few hours :)

It's near the top of my queue, I'm just debating what tree
to stick it into.

Probably I'll put it into net-next-2.6
