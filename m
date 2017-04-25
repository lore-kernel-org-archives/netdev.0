From: David Miller <davem@davemloft.net>
Subject: Re: macvlan: Fix device ref leak when purging bc_queue
Date: Tue, 25 Apr 2017 10:42:54 -0400 (EDT)
Message-ID: <20170425.104254.1884694182452846750.davem@davemloft.net>
References: <1492618528011.11322@Dell.com>
        <20170420125512.GA9113@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joe.Ghalam@dell.com, Clifford.Wichmann@dell.com,
        netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39760 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1947927AbdDYOm5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:42:57 -0400
In-Reply-To: <20170420125512.GA9113@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 Apr 2017 20:55:12 +0800

> When a parent macvlan device is destroyed we end up purging its
> broadcast queue without dropping the device reference count on
> the packet source device.  This causes the source device to linger.
> 
> This patch drops that reference count.
> 
> Fixes: 260916dfb48c ("macvlan: Fix potential use-after free for...")
> Reported-by: Joe Ghalam <Joe.Ghalam@dell.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks Herbert.
