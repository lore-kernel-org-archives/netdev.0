From: David Miller <davem@davemloft.net>
Subject: Re: [net-ipv4] question about arguments position
Date: Thu, 04 May 2017 12:46:00 -0400 (EDT)
Message-ID: <20170504.124600.627647229351638856.davem@davemloft.net>
References: <20170504110755.Horde.9md-X4baf8TwOEKjGrXkelZ@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: garsilva@embeddedor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57794 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755458AbdEDQqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:46:03 -0400
In-Reply-To: <20170504110755.Horde.9md-X4baf8TwOEKjGrXkelZ@gator4166.hostgator.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Date: Thu, 04 May 2017 11:07:54 -0500

> While looking into Coverity ID 1357474 I ran into the following piece
> of code at net/ipv4/inet_diag.c:392:

Because it's been this way since at least 2005, it doesn't matter if
the order is correct or not.  What's there is the locked in behavior
exposed to userspace and changing it will break things for people.
