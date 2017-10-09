From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: avoid zeroing per cpu data again
Date: Mon, 09 Oct 2017 10:30:02 -0700 (PDT)
Message-ID: <20171009.103002.37921790133920109.davem@davemloft.net>
References: <1507554097.31614.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com, tj@kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52606 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754494AbdJIRaC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:30:02 -0400
In-Reply-To: <1507554097.31614.11.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Oct 2017 06:01:37 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> per cpu allocations are already zeroed, no need to clear them again.
> 
> Fixes: d52d3997f843f ("ipv6: Create percpu rt6_info")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
