From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: memset ca_priv data to 0 properly
Date: Wed, 26 Apr 2017 14:59:07 -0400 (EDT)
Message-ID: <20170426.145907.1360570500747523374.davem@davemloft.net>
References: <20170426003802.40091-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
        ncardwell@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59496 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965606AbdDZS7J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:59:09 -0400
In-Reply-To: <20170426003802.40091-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Tue, 25 Apr 2017 17:38:02 -0700

> From: Wei Wang <weiwan@google.com>
> 
> Always zero out ca_priv data in tcp_assign_congestion_control() so that
> ca_priv data is cleared out during socket creation.
> Also always zero out ca_priv data in tcp_reinit_congestion_control() so
> that when cc algorithm is changed, ca_priv data is cleared out as well.
> We should still zero out ca_priv data even in TCP_CLOSE state because
> user could call connect() on AF_UNSPEC to disconnect the socket and
> leave it in TCP_CLOSE state and later call setsockopt() to switch cc
> algorithm on this socket.
> 
> Fixes: 2b0a8c9ee ("tcp: add CDG congestion control")
> Reported-by: Andrey Konovalov  <andreyknvl@google.com>
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied to 'net' and queued up for -stable, thanks.
