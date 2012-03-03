From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: corrupted IP fragments fix for large mtu.
Date: Fri, 02 Mar 2012 19:10:50 -0500 (EST)
Message-ID: <20120302.191050.206457824360172233.davem@davemloft.net>
References: <20120302144314.GB31240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbowler@elliptictech.com,
	hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757548Ab2CCAMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 19:12:03 -0500
In-Reply-To: <20120302144314.GB31240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Fri, 2 Mar 2012 15:43:14 +0100

> Noticed with the 8168d (-vb-gr, aka RTL_GIGA_MAC_VER_26).
> 
> ConfigX registers should only be written while the Config9346 lock
> is held.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Reported-by: Nick Bowler <nbowler@elliptictech.com>
> Cc: Hayes Wang <hayeswang@realtek.com>

Applied and queued up for -stable, thanks a lot.
