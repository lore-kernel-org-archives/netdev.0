From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: restrict F-RTO to work-around broken
 middle-boxes
Date: Fri, 07 Apr 2017 11:45:11 -0700 (PDT)
Message-ID: <20170407.114511.2181178908974978179.davem@davemloft.net>
References: <20170407184205.168217-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754489AbdDGSpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 14:45:13 -0400
In-Reply-To: <20170407184205.168217-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri,  7 Apr 2017 11:42:05 -0700

> The recent extension of F-RTO 89fe18e44 ("tcp: extend F-RTO
> to catch more spurious timeouts") interacts badly with certain
> broken middle-boxes.  These broken boxes modify and falsely raise
> the receive window on the ACKs. During a timeout induced recovery,
> F-RTO would send new data packets to probe if the timeout is false
> or not. Since the receive window is falsely raised, the receiver
> would silently drop these F-RTO packets. The recovery would take N
> (exponentially backoff) timeouts to repair N packet losses.  A TCP
> performance killer.
> 
> Due to this unfortunate situation, this patch removes this extension
> to revert F-RTO back to the RFC specification.
> 
> Fixes: 89fe18e44f7e ("tcp: extend F-RTO to catch more spurious timeouts")
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thank you.
