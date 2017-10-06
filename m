From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] tcp: clean up TFO server's initial
 tcp_rearm_rto() call
Date: Thu, 05 Oct 2017 21:10:49 -0700 (PDT)
Message-ID: <20171005.211049.948056171839883718.davem@davemloft.net>
References: <20171004170404.132419-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
        edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751459AbdJFEKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 00:10:50 -0400
In-Reply-To: <20171004170404.132419-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Wed,  4 Oct 2017 10:04:04 -0700

> From: Wei Wang <weiwan@google.com>
> 
> This commit does a cleanup and moves tcp_rearm_rto() call in the TFO
> server case into a previous spot in tcp_rcv_state_process() to make
> it more compact.
> This is only a cosmetic change.
> 
> Suggested-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Wei Wang <weiwan@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied.
