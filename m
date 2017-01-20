From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fq_codel: Avoid regenerating skb flow hash
 unless necessary
Date: Fri, 20 Jan 2017 12:15:37 -0500 (EST)
Message-ID: <20170120.121537.2279655261253689807.davem@davemloft.net>
References: <20170118210428.24006-1-acollins@cradlepoint.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, tom@herbertland.com
To: acollins@cradlepoint.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752248AbdATRPj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:15:39 -0500
In-Reply-To: <20170118210428.24006-1-acollins@cradlepoint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Collins <acollins@cradlepoint.com>
Date: Wed, 18 Jan 2017 14:04:28 -0700

> The fq_codel qdisc currently always regenerates the skb flow hash.
> This wastes some cycles and prevents flow seperation in cases where
> the traffic has been encrypted and can no longer be understood by the
> flow dissector.
> 
> Change it to use the prexisting flow hash if one exists, and only
> regenerate if necessary.
> 
> Signed-off-by: Andrew Collins <acollins@cradlepoint.com>

Applied, thanks.
