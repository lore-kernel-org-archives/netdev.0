From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: refine bond_fold_stats() wrap
 detection
Date: Thu, 30 Mar 2017 12:41:11 -0700 (PDT)
Message-ID: <20170330.124111.1039054272421787555.davem@davemloft.net>
References: <1490809544.24891.45.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@cumulusnetworks.com,
        j.vosburgh@gmail.com, vfalico@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934091AbdC3TlN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 15:41:13 -0400
In-Reply-To: <1490809544.24891.45.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 29 Mar 2017 10:45:44 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Some device drivers reset their stats at down/up events, possibly
> fooling bonding stats, since they operate with relative deltas.
> 
> It is nearly not possible to fix drivers, since some of them compute the
> tx/rx counters based on per rx/tx queue stats, and the queues can be
> reconfigured (ethtool -L) between the down/up sequence.
> 
> Lets avoid accumulating 'negative' values that render bonding stats
> useless.
> 
> It is better to lose small deltas, assuming the bonding stats are
> fetched at a reasonable frequency.
> 
> Fixes: 5f0c5f73e5ef ("bonding: make global bonding stats more reliable")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
