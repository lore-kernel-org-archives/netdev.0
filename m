From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] tcp: fix reordering SNMP under-counting
Date: Wed, 05 Apr 2017 18:42:01 -0700 (PDT)
Message-ID: <20170405.184201.2156445090158367134.davem@davemloft.net>
References: <20170404211540.47887-1-ycheng@google.com>
        <20170404211540.47887-2-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49016 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756315AbdDFBmC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 21:42:02 -0400
In-Reply-To: <20170404211540.47887-2-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue,  4 Apr 2017 14:15:40 -0700

> Currently the reordering SNMP counters only increase if a connection
> sees a higher degree then it has previously seen. It ignores if the
> reordering degree is not greater than the default system threshold.
> This significantly under-counts the number of reordering events
> and falsely convey that reordering is rare on the network.
> 
> This patch properly and faithfully records the number of reordering
> events detected by the TCP stack, just like the comment says "this
> exciting event is worth to be remembered". Note that even so TCP
> still under-estimate the actual reordering events because TCP
> requires TS options or certain packet sequences to detect reordering
> (i.e. ACKing never-retransmitted sequence in recovery or disordered
>  state).
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Applied.
