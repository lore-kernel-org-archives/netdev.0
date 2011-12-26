From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Mon, 26 Dec 2011 15:17:13 -0500 (EST)
Message-ID: <20111226.151713.2002746283994460284.davem@davemloft.net>
References: <4EED3A3D.9080503@gentoo.org>
	<4EF6803C.9060203@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: kumba@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab1LZURY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 15:17:24 -0500
In-Reply-To: <4EF6803C.9060203@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joshua Kinard <kumba@gentoo.org>
Date: Sat, 24 Dec 2011 20:45:32 -0500

> SGI IP32 (O2)'s ethernet driver (meth) lacks meth_set_rx_mode, which
> prevents IPv6 from working completely because any ICMPv6 neighbor
> solicitation requests aren't picked up by the driver.  So the machine can
> ping out and connect to other systems, but other systems will have a very
> hard time connecting to the O2.
> 
> Signed-off-by: Joshua Kinard <kumba@gentoo.org>

Lots of completely unrelated changes here, the IRQ name string has
nothing to do with specifically fixing the ICMPv6 neighbour discovery
bug.

Do not mix changes like this, one change per patch please, thanks.
