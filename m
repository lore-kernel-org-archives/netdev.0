From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: avoid setting cwnd to invalid ssthresh after
 cwnd reduction states
Date: Wed, 02 Aug 2017 10:51:36 -0700 (PDT)
Message-ID: <20170802.105136.1599120748083773522.davem@davemloft.net>
References: <20170801202232.162176-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55122 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751994AbdHBRvg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 13:51:36 -0400
In-Reply-To: <20170801202232.162176-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue,  1 Aug 2017 13:22:32 -0700

> If the sender switches the congestion control during ECN-triggered
> cwnd-reduction state (CA_CWR), upon exiting recovery cwnd is set to
> the ssthresh value calculated by the previous congestion control. If
> the previous congestion control is BBR that always keep ssthresh
> to TCP_INIFINITE_SSTHRESH, cwnd ends up being infinite. The safe
> step is to avoid assigning invalid ssthresh value when recovery ends.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks.

Is this a -stable candidate?
