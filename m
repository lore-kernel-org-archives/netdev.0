From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp/dccp: drop SYN packets if accept queue is
 full
Date: Sat, 29 Oct 2016 15:09:48 -0400 (EDT)
Message-ID: <20161029.150948.1138589874373025111.davem@davemloft.net>
References: <1477499277.7065.193.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51948 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751609AbcJ2TJu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 15:09:50 -0400
In-Reply-To: <1477499277.7065.193.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 Oct 2016 09:27:57 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Per listen(fd, backlog) rules, there is really no point accepting a SYN,
> sending a SYNACK, and dropping the following ACK packet if accept queue
> is full, because application is not draining accept queue fast enough.
> 
> This behavior is fooling TCP clients that believe they established a
> flow, while there is nothing at server side. They might then send about
> 10 MSS (if using IW10) that will be dropped anyway while server is under
> stress.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
