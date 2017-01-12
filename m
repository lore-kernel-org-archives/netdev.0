From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] secure_seq: fix sparse errors
Date: Thu, 12 Jan 2017 15:57:39 -0500 (EST)
Message-ID: <20170112.155739.388347823509486932.davem@davemloft.net>
References: <1484187037.15816.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jason@zx2c4.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57388 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750761AbdALU5p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:57:45 -0500
In-Reply-To: <1484187037.15816.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Jan 2017 18:10:37 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Fixes following warnings :
> 
> net/core/secure_seq.c:125:28: warning: incorrect type in argument 1
> (different base types)
> net/core/secure_seq.c:125:28:    expected unsigned int const [unsigned]
> [usertype] a
> net/core/secure_seq.c:125:28:    got restricted __be32 [usertype] saddr
> net/core/secure_seq.c:125:35: warning: incorrect type in argument 2
> (different base types)
> net/core/secure_seq.c:125:35:    expected unsigned int const [unsigned]
> [usertype] b
> net/core/secure_seq.c:125:35:    got restricted __be32 [usertype] daddr
> net/core/secure_seq.c:125:43: warning: cast from restricted __be16
> net/core/secure_seq.c:125:61: warning: restricted __be16 degrades to
> integer
> 
> 
> Fixes: 7cd23e5300c1 ("secure_seq: use SipHash in place of MD5")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
