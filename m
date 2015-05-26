From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: remove one sparse error
Date: Mon, 25 May 2015 20:28:43 -0400 (EDT)
Message-ID: <20150525.202843.1224223950662769355.davem@davemloft.net>
References: <1432595197.4060.201.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47743 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbbEZA2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 20:28:44 -0400
In-Reply-To: <1432595197.4060.201.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 25 May 2015 16:06:37 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> net/core/pktgen.c:2672:43: warning: incorrect type in assignment (different base types)
> net/core/pktgen.c:2672:43:    expected unsigned short [unsigned] [short] [usertype] <noident>
> net/core/pktgen.c:2672:43:    got restricted __be16 [usertype] protocol
> 
> Let's use proper struct ethhdr instead of hard coding everything.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
