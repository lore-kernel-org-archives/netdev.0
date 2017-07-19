From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: adjust tail loss probe timeout
Date: Wed, 19 Jul 2017 16:19:22 -0700 (PDT)
Message-ID: <20170719.161922.2049573872575990119.davem@davemloft.net>
References: <20170719224126.103086-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48832 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753859AbdGSXTW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 19:19:22 -0400
In-Reply-To: <20170719224126.103086-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 19 Jul 2017 15:41:26 -0700

> This patch adjusts the timeout formula to schedule the TCP loss probe
> (TLP). The previous formula uses 2*SRTT or 1.5*RTT + DelayACKMax if
> only one packet is in flight. It keeps a lower bound of 10 msec which
> is too large for short RTT connections (e.g. within a data-center).
> The new formula = 2*RTT + (inflight == 1 ? 200ms : 2ticks) which
> performs better for short and fast connections.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks!
