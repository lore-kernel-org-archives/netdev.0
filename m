From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: tcp_rack_reo_timeout() must update
 tp->tcp_mstamp
Date: Thu, 27 Apr 2017 11:46:46 -0400 (EDT)
Message-ID: <20170427.114646.1132727678105640160.davem@davemloft.net>
References: <1493266255.6453.103.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, ncardwell@google.com,
        ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42314 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031359AbdD0Pqz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 11:46:55 -0400
In-Reply-To: <1493266255.6453.103.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Apr 2017 21:10:55 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I wrongly assumed tp->tcp_mstamp was up to date at the time
> tcp_rack_reo_timeout() was called.
> 
> It is not true, since we only update tcp->tcp_mstamp when receiving
> a packet (as initially done in commit 69e996c58a35 ("tcp: add
> tp->tcp_mstamp field")
> 
> tcp_rack_reo_timeout() being called by a timer and not an incoming
> packet, we need to refresh tp->tcp_mstamp
> 
> Fixes: 7c1c7308592f ("tcp: do not pass timestamp to tcp_rack_detect_loss()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
