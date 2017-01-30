From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers: net: generalize napi_complete_done()
Date: Mon, 30 Jan 2017 15:11:20 -0500 (EST)
Message-ID: <20170130.151120.835559657363649393.davem@davemloft.net>
References: <20170130162201.8459-1-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752362AbdA3ULW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:11:22 -0500
In-Reply-To: <20170130162201.8459-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Mon, 30 Jan 2017 08:22:01 -0800

> napi_complete_done() allows to opt-in for gro_flush_timeout,
> added back in linux-3.19, commit 3b47d30396ba
> ("net: gro: add a per device gro flush timer")
> 
> This allows for more efficient GRO aggregation without
> sacrifying latencies.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good to me.

Will push it out assuming it passes my build tests.

Thanks!
