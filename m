From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: reduce skb overhead in selected places
Date: Wed, 25 Jan 2017 14:03:02 -0500 (EST)
Message-ID: <20170125.140302.1425628250874176845.davem@davemloft.net>
References: <1485298656.16328.355.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170125.131717.489451306351372553.davem@davemloft.net>
        <1485369532.5145.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59390 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752479AbdAYTDV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:03:21 -0500
In-Reply-To: <1485369532.5145.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Jan 2017 10:38:52 -0800

> Do you think we could change __pskb_pull_tail() right away and fix the
> few places that would break, or should we add various helpers with extra
> parameters to take a safe route ?

It should always be safe as long as we see no socket attached on RX,
right?

That's the only real case where truesize adjustments can cause trouble.
