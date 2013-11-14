From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix possible seqlock deadlock
Date: Thu, 14 Nov 2013 17:32:47 -0500 (EST)
Message-ID: <20131114.173247.1356465090660629003.davem@davemloft.net>
References: <20131114191621.GB9630@redhat.com>
	<1384458103.28716.33.camel@edumazet-glaptop2.roam.corp.google.com>
	<1384465074.28716.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754375Ab3KNWct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 17:32:49 -0500
In-Reply-To: <1384465074.28716.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Nov 2013 13:37:54 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> ip4_datagram_connect() being called from process context,
> it should use IP_INC_STATS() instead of IP_INC_STATS_BH()
> otherwise we can deadlock on 32bit arches, or get corruptions of
> SNMP counters.
> 
> Fixes: 584bdf8cbdf6 ("[IPV4]: Fix "ipOutNoRoutes" counter error for TCP and UDP")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dave Jones <davej@redhat.com>

Applied and queued up for -stable, thanks!
