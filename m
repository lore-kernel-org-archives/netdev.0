From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Remove deprecated print_mac to fix warnings
Date: Sun, 6 Dec 2009 20:19:26 +0100
Message-ID: <20091206191926.GX18989@one.firstfloor.org>
References: <20091206140828.GA8600@basil.fritz.box> <20091206.111739.40602157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:57781 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757359AbZLFTTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 14:19:22 -0500
Content-Disposition: inline
In-Reply-To: <20091206.111739.40602157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 06, 2009 at 11:17:39AM -0800, David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Sun, 6 Dec 2009 15:08:28 +0100
> 
> > Remove deprecated and unused print_mac to fix warnings
> > 
> > There seems to be no user in tree of print_mac left. So just remove it.
> > 
> > This eliminates two compiler warnings for every build, because gcc
> > complains about the deprecated use of the symbol in its EXPORT_SYMBOL.
> > 
> > Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> davem@sunset:~/src/GIT/net-next-2.6$ git grep print_mac
> davem@sunset:~/src/GIT/net-next-2.6$ 

Great. I grepped in linux-next, but perhaps I raced with you.

But could that please be fixed in a 2.6.32 stable too? the warnings 
on every build are annoying.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
