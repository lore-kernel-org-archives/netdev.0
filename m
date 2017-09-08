From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp: drop head states only when all skb references
 are gone
Date: Thu, 07 Sep 2017 20:03:05 -0700 (PDT)
Message-ID: <20170907.200305.1453658712948209622.davem@davemloft.net>
References: <1504631927.15310.47.camel@edumazet-glaptop3.roam.corp.google.com>
        <1d0596e2a1926e7c0e8c7f691ef42c713daa3396.1504701206.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41612 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753132AbdIHDDH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 23:03:07 -0400
In-Reply-To: <1d0596e2a1926e7c0e8c7f691ef42c713daa3396.1504701206.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed,  6 Sep 2017 14:44:36 +0200

> After commit 0ddf3fb2c43d ("udp: preserve skb->dst if required
> for IP options processing") we clear the skb head state as soon
> as the skb carrying them is first processed.
> 
> Since the same skb can be processed several times when MSG_PEEK
> is used, we can end up lacking the required head states, and
> eventually oopsing.
> 
> Fix this clearing the skb head state only when processing the
> last skb reference.
> 
> Reported-by: Eric Dumazet <edumazet@google.com>
> Fixes: 0ddf3fb2c43d ("udp: preserve skb->dst if required for IP options processing")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable, thanks.
