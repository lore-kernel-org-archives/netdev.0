From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: align tcp_xmit_size_goal() on
 tcp_tso_autosize()
Date: Thu, 05 Mar 2015 22:31:26 -0500 (EST)
Message-ID: <20150305.223126.2026710566547866821.davem@davemloft.net>
References: <1425571386.5130.247.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752743AbbCFDb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 22:31:28 -0500
In-Reply-To: <1425571386.5130.247.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Mar 2015 08:03:06 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> With some mss values, it is possible tcp_xmit_size_goal() puts
> one segment more in TSO packet than tcp_tso_autosize().
> 
> We send then one TSO packet followed by one single MSS.
> 
> It is not a serious bug, but we can do slightly better, especially
> for drivers using netif_set_gso_max_size() to lower gso_max_size.
> 
> Using same formula avoids these corner cases and makes
> tcp_xmit_size_goal() a bit faster.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 605ad7f184b6 ("tcp: refine TSO autosizing")

Applied, thanks Eric.
