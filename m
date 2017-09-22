From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: remove skb_dst_force() after
 skb_dst_set()
Date: Thu, 21 Sep 2017 20:36:51 -0700 (PDT)
Message-ID: <20170921.203651.310414522133227165.davem@davemloft.net>
References: <1506005428.29839.129.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
        shm@cumulusnetworks.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdIVDgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 23:36:52 -0400
In-Reply-To: <1506005428.29839.129.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 21 Sep 2017 07:50:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> skb_dst_set(skb, dst) installs a normal (refcounted) dst, there is no
> point using skb_dst_force(skb)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
