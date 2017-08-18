From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tipc: fix use-after-free
Date: Fri, 18 Aug 2017 16:00:12 -0700 (PDT)
Message-ID: <20170818.160012.1862120618297477185.davem@davemloft.net>
References: <1502901714.4936.126.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
        ying.xue@windriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34432 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdHRXAM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:00:12 -0400
In-Reply-To: <1502901714.4936.126.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Aug 2017 09:41:54 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syszkaller reported use-after-free in tipc [1]
> 
> When msg->rep skb is freed, set the pointer to NULL,
> so that caller does not free it again.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov  <dvyukov@google.com>

Applied and queued up for -stable, thanks Eric.
