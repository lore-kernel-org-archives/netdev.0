From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: move ethtool include to where its used
Date: Sat, 04 Feb 2012 16:23:31 -0500 (EST)
Message-ID: <20120204.162331.1482938799603820869.davem@davemloft.net>
References: <1328267822-25690-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956Ab2BDVXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:23:38 -0500
In-Reply-To: <1328267822-25690-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Fri,  3 Feb 2012 06:17:02 -0500

> The linux/mii.h headers has long been standalone for userspace.  But a
> recent commit added linux/ethtool.h to the include list even when it
> isn't used.  Since we only need this with __KERNEL__, move the include
> down to the right spot.  Now userland no longer needs to pull this in.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

I don't understand what the problem is.

linux/ethtool.h is a safely exported header file for userspace,
so if linux/mii.h now starts to include it this should make no
difference whatsoever for userspace unless userspace does something
bogus which in turn would mean it's almost certainly userspace
which is at fault here no the kernel headers.

You don't describe the exact nature of the failure nor have you shown
a specific actual failure, so we can only guess what the real problem
is.  And that's another thing that makes this patch submission bogus.

This change seems arbitrary and not necessary, therefore I am not
applying it.
