From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_red: generalize accurate MAX_P support to
 RED/GRED/CHOKE
Date: Fri, 09 Dec 2011 13:46:45 -0500 (EST)
Message-ID: <20111209.134645.470426835770901939.davem@davemloft.net>
References: <20111208092130.656c39ff@nehalam.linuxnetplumber.net>
	<1323368188.2529.4.camel@edumazet-laptop>
	<1323434805.2336.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dave.taht@gmail.com, netdev@vger.kernel.org,
	hagen@jauu.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518Ab1LISqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 13:46:51 -0500
In-Reply-To: <1323434805.2336.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 09 Dec 2011 13:46:45 +0100

> Now RED uses a Q0.32 number to store max_p (max probability), allow
> RED/GRED/CHOKE to use/report full resolution at config/dump time.
> 
> Old tc binaries are non aware of new attributes, and still set/get Plog.
> 
> New tc binary set/get both Plog and max_p for backward compatibility,
> they display "probability value" if they get max_p from new kernels.
> 
> # tc -d  qdisc show dev ...
> ...
> qdisc red 10: parent 1:1 limit 360Kb min 30Kb max 90Kb ecn ewma 5
> probability 0.09 Scell_log 15
> 
> Make sure we avoid potential divides by 0 in reciprocal_value(), if
> (max_th - min_th) is big.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
