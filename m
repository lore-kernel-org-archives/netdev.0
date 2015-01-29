From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: fq: remove useless TIME_WAIT check
Date: Wed, 28 Jan 2015 23:24:21 -0800 (PST)
Message-ID: <20150128.232421.1780933715008005387.davem@davemloft.net>
References: <1422453996.29618.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36848 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbbA2HYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 02:24:21 -0500
In-Reply-To: <1422453996.29618.64.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Jan 2015 06:06:36 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> TIME_WAIT sockets are not owning any skb.
> 
> ip_send_unicast_reply() and tcp_v6_send_response() both use
> regular sockets.
> 
> We can safely remove a test in sch_fq and save one cache line miss,
> as sk_state is far away from sk_pacing_rate.
> 
> Tested at Google for about one year.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
