From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] pkt_sched: fq: clear time_next_packet for reused
 flows
Date: Mon, 28 Oct 2013 00:19:00 -0400 (EDT)
Message-ID: <20131028.001900.1319120433161523077.davem@davemloft.net>
References: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
	<1382916403.4045.17.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab3J1ETB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 00:19:01 -0400
In-Reply-To: <1382916403.4045.17.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 27 Oct 2013 16:26:43 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When a socket is freed/reallocated, we need to clear time_next_packet
> or else we can inherit a prior value and delay first packets of the
> new flow.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
