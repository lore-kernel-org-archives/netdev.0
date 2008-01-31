From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 19:37:35 +0100
Message-ID: <20080131183735.GC4671@one.firstfloor.org>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49104 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759751AbYAaSDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:03:09 -0500
Content-Disposition: inline
In-Reply-To: <47A20CDC.5090104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 07:01:00PM +0100, Patrick McHardy wrote:
> Andi Kleen wrote:
> >>Fix the broken qdisc instead.
> >
> >What do you mean? I don't think the qdiscs are broken.
> >I cannot think of any way how e.g. TBF can do anything useful
> >with large TSO packets.
> 
> 
> Someone posted a patch some time ago to calculate the amount
> of tokens needed in max_size portions and use that, but IMO
> people should just configure TBF with the proper MTU for TSO.

TBF with 64k atomic units will always be chunky and uneven. I don't
think that's a useful goal. 

-Andi

