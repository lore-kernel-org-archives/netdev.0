From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: initialize icsk_ack.lrcvtime at session start
 time
Date: Wed, 22 Mar 2017 15:40:11 -0700 (PDT)
Message-ID: <20170322.154011.793246495784624746.davem@davemloft.net>
References: <1490195421.16816.157.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752680AbdCVWkM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 18:40:12 -0400
In-Reply-To: <1490195421.16816.157.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Mar 2017 08:10:21 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> icsk_ack.lrcvtime has a 0 value at socket creation time.
> 
> tcpi_last_data_recv can have bogus value if no payload is ever received.
> 
> This patch initializes icsk_ack.lrcvtime for active sessions
> in tcp_finish_connect(), and for passive sessions in
> tcp_create_openreq_child()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
