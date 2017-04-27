From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fib: Decrease one unnecessary rt cache flush in
 fib_disable_ip
Date: Thu, 27 Apr 2017 16:33:51 -0400 (EDT)
Message-ID: <20170427.163351.27245691786176107.davem@davemloft.net>
References: <1493204644-88477-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fgao@ikuai8.com
To: gfree.wind@foxmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751500AbdD0Udx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 16:33:53 -0400
In-Reply-To: <1493204644-88477-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gfree.wind@foxmail.com
Date: Wed, 26 Apr 2017 19:04:04 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> The func fib_flush already flushes the rt cache if necessary, so it
> is not necessary to invoke rt_cache_flush again in fib_disable_ip.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Looks good, applied to net-next, thanks!
