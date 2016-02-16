From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: do not set rtt_min to 1
Date: Tue, 16 Feb 2016 16:07:48 -0500 (EST)
Message-ID: <20160216.160748.705097911861027818.davem@davemloft.net>
References: <1455209898.22120.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932311AbcBPVHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 16:07:50 -0500
In-Reply-To: <1455209898.22120.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Feb 2016 08:58:18 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> There are some cases where rtt_us derives from deltas of jiffies,
> instead of using usec timestamps.
> 
> Since we want to track minimal rtt, better to assume a delta of 0 jiffie
> might be in fact be very close to 1 jiffie.
> 
> It is kind of sad jiffies_to_usecs(1) calls a function instead of simply
> using a constant.
> 
> Fixes: f672258391b42 ("tcp: track min RTT using windowed min-filter")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Applied and queued up for -stable, thanks Eric.
