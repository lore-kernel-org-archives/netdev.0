From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_grow_window() for large incoming frames
Date: Tue, 17 Apr 2012 22:33:37 -0400 (EDT)
Message-ID: <20120417.223337.180186800931720005.davem@davemloft.net>
References: <1334654887.2472.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792Ab2DRCdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:33:41 -0400
In-Reply-To: <1334654887.2472.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Apr 2012 11:28:07 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_grow_window() has to grow rcv_ssthresh up to window_clamp, allowing
> sender to increase its window.
> 
> tcp_grow_window() still assumes a tcp frame is under MSS, but its no
> longer true with LRO/GRO.
> 
> This patch fixes one of the performance issue we noticed with GRO on.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
