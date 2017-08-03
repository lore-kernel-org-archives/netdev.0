From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/3] tcp: fix xmit timer rearming to avoid stalls
Date: Thu, 03 Aug 2017 15:39:06 -0700 (PDT)
Message-ID: <20170803.153906.734255383584818482.davem@davemloft.net>
References: <20170803131954.15441-1-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752011AbdHCWjH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 18:39:07 -0400
In-Reply-To: <20170803131954.15441-1-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu,  3 Aug 2017 09:19:51 -0400

> This patch series is a bug fix for a TCP loss recovery performance bug
> reported independently in recent netdev threads:
>     
>  (i)  July 26, 2017: netdev thread "TCP fast retransmit issues"
>  (ii) July 26, 2017: netdev thread:
>        "[PATCH V2 net-next] TLP: Don't reschedule PTO when there's one
>        outstanding TLP retransmission"
> 
> Many thanks to Klavs Klavsen and Mao Wenan for the detailed reports,
> traces, and packetdrill test cases, which enabled us to root-cause
> this issue and verify the fix.
> 
> - v1 -> v2:
>  - In patch 2/3, changed an unclear comment in the pre-existing code
>    in tcp_schedule_loss_probe() to be more clear (thanks to Eric Dumazet
>    for suggesting we improve this).

Series applied, thanks Neal.
