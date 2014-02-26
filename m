From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 net-next 2/2] tcp: switch rtt estimations to usec
 resolution
Date: Wed, 26 Feb 2014 17:04:39 -0500 (EST)
Message-ID: <20140226.170439.506202474296777480.davem@davemloft.net>
References: <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393309341.2316.120.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393452168.26794.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, ja@ssi.bg, ycheng@google.com,
	netdev@vger.kernel.org, ncardwell@google.com, brakmo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41423 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754317AbaBZWEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 17:04:41 -0500
In-Reply-To: <1393452168.26794.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Feb 2014 14:02:48 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Upcoming congestion controls for TCP require usec resolution for RTT
> estimations. Millisecond resolution is simply not enough these days.
> 
> FQ/pacing in DC environments also require this change for finer control
> and removal of bimodal behavior due to the current hack in
> tcp_update_pacing_rate() for 'small rtt'
> 
> TCP_CONG_RTT_STAMP is no longer needed.
> 
> As Julian Anastasov pointed out, we need to keep user compatibility :
> tcp_metrics used to export RTT and RTTVAR in msec resolution,
> so we added RTT_US and RTTVAR_US. An iproute2 patch is needed
> to use the new attributes if provided by the kernel.
> 
 ...
> With help from Julian Anastasov, Stephen Hemminger and Yuchung Cheng
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks everyone.
