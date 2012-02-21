From: David Miller <davem@davemloft.net>
Subject: Re: 3.3-rc3+ Crash in __neigh_for_each_release
Date: Tue, 21 Feb 2012 17:46:26 -0500 (EST)
Message-ID: <20120221.174626.483958348601999244.davem@davemloft.net>
References: <20120221.140716.1396286389544946379.davem@davemloft.net>
	<1329851756.18384.47.camel@edumazet-laptop>
	<1329857209.18384.53.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756195Ab2BUWqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 17:46:31 -0500
In-Reply-To: <1329857209.18384.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 21:46:49 +0100

> [PATCH] atm: clip: remove clip_tbl
> 
> Commit 32092ecf0644 (atm: clip: Use device neigh support on top of
> "arp_tbl".) introduced a bug since clip_tbl is zeroed : Crash occurs in
> __neigh_for_each_release()
> 
> idle_timer_check() must use instead arp_tbl and neigh_check_cb() should
> ignore non clip neighbours.
> 
> Idea from David Miller.
> 
> Reported-by: Meelis Roos <mroos@linux.ee>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Yep, this looks a lot better, once we have positive testing from
Meelis I'll apply this.

Thanks.
