From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] ipv6: udp: exploit dev_scratch helpers
Date: Tue, 27 Jun 2017 15:44:17 -0400 (EDT)
Message-ID: <20170627.154417.863004930892362291.davem@davemloft.net>
References: <cover.1498493975.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753444AbdF0ToX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 15:44:23 -0400
In-Reply-To: <cover.1498493975.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon, 26 Jun 2017 19:01:49 +0200

> When bringing in the recent cache optimization for the UDP protocol, I forgot
> to leverage the newly introduced scratched area helpers in the UDPv6 code path.
> As a result, the UDPv6 implementation suffers some unnecessary performance
> penality when compared to v4.
> 
> This series aim to bring back UDPv6 on equal footing in respect to v4.
> The first patch moves the shared helpers to the common include files, while
> the second uses them in the UDPv6 code.
> 
> This gives 5-8% performance improvement for a system under flood with small
> UDPv6 packets. The performance delta is less than the one reported on the
> original patch set because the UDPv6 code path already leveraged some of the
> optimization.

Series applied, thank you.
