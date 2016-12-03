From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: gen_estimator: account for timer
 drifts
Date: Sat, 03 Dec 2016 16:12:34 -0500 (EST)
Message-ID: <20161203.161234.605773166761239343.davem@davemloft.net>
References: <1480695060.18162.363.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37482 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750873AbcLCVTh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 16:19:37 -0500
In-Reply-To: <1480695060.18162.363.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Dec 2016 08:11:00 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Under heavy stress, timer used in estimators tend to slowly be delayed
> by a few jiffies, leading to inaccuracies.
> 
> Lets remember what was the last scheduled jiffies so that we get more
> precise estimations, without having to add a multiply/divide in the loop
> to account for the drifts.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
