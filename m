From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp: re-add header prediction
Date: Wed, 30 Aug 2017 11:20:51 -0700 (PDT)
Message-ID: <20170830.112051.1883418035935384084.davem@davemloft.net>
References: <20170830172458.18544-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58630 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752090AbdH3SUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 14:20:53 -0400
In-Reply-To: <20170830172458.18544-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 30 Aug 2017 19:24:56 +0200

> Eric reported a performance regression caused by header prediction
> removal.
> 
> We now call tcp_ack() much more frequently, for some workloads
> this brings in enough cache line misses to become noticeable.
> 
> We could possibly still kill HP provided we find a different
> way to suppress unneeded tcp_ack, but given we're late in
> the cycle it seems preferable to revert.

Indeed, reverting at this point in the game is the best thing
to do right now.

Applied, thanks.
