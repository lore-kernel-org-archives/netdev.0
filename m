From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Tue, 27 Dec 2011 13:17:43 -0500 (EST)
Message-ID: <20111227.131743.1555029258883745131.davem@davemloft.net>
References: <4EED3A3D.9080503@gentoo.org>
	<4EF95247.7000403@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
To: kumba@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720Ab1L0SRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 13:17:54 -0500
In-Reply-To: <4EF95247.7000403@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joshua Kinard <kumba@gentoo.org>
Date: Tue, 27 Dec 2011 00:06:15 -0500

> SGI IP32 (O2)'s ethernet driver (meth) lacks a set_rx_mode function, which
> prevents IPv6 from working completely because any ICMPv6 neighbor
> solicitation requests aren't picked up by the driver.  So the machine can
> ping out and connect to other systems, but other systems will have a very
> hard time connecting to the O2.
> 
> Signed-off-by: Joshua Kinard <kumba@gentoo.org>

Applied to net-next, thanks.
