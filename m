From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] secure_seq: downgrade to per-host timestamp offsets
Date: Fri, 24 Mar 2017 19:28:26 -0700 (PDT)
Message-ID: <20170324.192826.11282993769447164.davem@davemloft.net>
References: <20170324184237.16044-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, edumazet@google.com,
        ncardwell@google.com, ycheng@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48126 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937053AbdCYC21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 22:28:27 -0400
In-Reply-To: <20170324184237.16044-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 24 Mar 2017 19:42:37 +0100

> Unfortunately too many devices (not under our control) use tcp_tw_recycle=1,
> which depends on timestamps being identical of the same saddr.
> 
> Although tcp_tw_recycle got removed in net-next we can't make
> such end hosts disappear so downgrade to per-host timestamp offsets.
> 
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Reported-by: Yvan Vanrossomme <yvan@vanrossomme.net>
> Fixes: 95a22caee396c ("tcp: randomize tcp timestamp offsets for each connection")
> Signed-off-by: Florian Westphal <fw@strlen.de>

Ok, applied and queued up for -stable.

> David, I can cook a stable patch using jhash if needed, just let me know
> (siphash was added after 4.10).

Yes, I'll need that, thanks!
