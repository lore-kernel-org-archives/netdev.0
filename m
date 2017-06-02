From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove unnecessary
 skb_reset_tail_pointer()
Date: Fri, 02 Jun 2017 14:28:47 -0400 (EDT)
Message-ID: <20170602.142847.694931058541946958.davem@davemloft.net>
References: <1496351916.27480.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750971AbdFBS2s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 14:28:48 -0400
In-Reply-To: <1496351916.27480.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Jun 2017 14:18:36 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> __pskb_trim_head() does not need to reset skb tail pointer.
> 
> Also change the comments, __pskb_pull_head() does not exist.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
