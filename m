From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: introduce SO_MAX_PACING_RATE
Date: Sat, 28 Sep 2013 15:36:10 -0700 (PDT)
Message-ID: <20130928.153610.2280100769720851440.davem@davemloft.net>
References: <1379949014.3165.24.camel@edumazet-glaptop>
	<1380036052.3165.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sesse@google.com, mtk.manpages@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33900 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238Ab3I1W3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 18:29:11 -0400
In-Reply-To: <1380036052.3165.71.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Sep 2013 08:20:52 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As mentioned in commit afe4fd062416b ("pkt_sched: fq: Fair Queue packet
> scheduler"), this patch adds a new socket option.
> 
> SO_MAX_PACING_RATE offers the application the ability to cap the
> rate computed by transport layer. Value is in bytes per second.
> 
> u32 val = 1000000;
> setsockopt(sockfd, SOL_SOCKET, SO_MAX_PACING_RATE, &val, sizeof(val));
> 
> To be effectively paced, a flow must use FQ packet scheduler.
> 
> Note that a packet scheduler takes into account the headers for its
> computations. The effective payload rate depends on MSS and retransmits
> if any.
> 
> I chose to make this pacing rate a SOL_SOCKET option instead of a
> TCP one because this can be used by other protocols.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
