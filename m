From: David Miller <davem@davemloft.net>
Subject: Re: 3.3-rc3+ Crash in __neigh_for_each_release
Date: Tue, 21 Feb 2012 14:07:16 -0500 (EST)
Message-ID: <20120221.140716.1396286389544946379.davem@davemloft.net>
References: <alpine.SOC.1.00.1202201359190.8004@math.ut.ee>
	<1329851004.18384.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59327 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848Ab2BUTHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 14:07:22 -0500
In-Reply-To: <1329851004.18384.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Feb 2012 20:03:24 +0100

> But I dont know enough this code to know if the following patch is the
> way to fix this. (and __neigh_for_each_release() can also be deleted if
> no users left in tree)

I think instead of removing the code, we need to have it iterate over
"arp_tbl" but only invoke the callback for devices which are of type
ATM.
