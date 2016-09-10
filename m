From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_tunnel: do not clear l4 hashes
Date: Fri, 09 Sep 2016 19:35:34 -0700 (PDT)
Message-ID: <20160909.193534.2080359058444961122.davem@davemloft.net>
References: <1473374448.18970.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752626AbcIJCff (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 22:35:35 -0400
In-Reply-To: <1473374448.18970.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 08 Sep 2016 15:40:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> If skb has a valid l4 hash, there is no point clearing hash and force
> a further flow dissection when a tunnel encapsulation is added.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
