From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] strparser: Use delayed work instead of timer
 for msg timeout
Date: Wed, 25 Oct 2017 10:37:34 +0900 (KST)
Message-ID: <20171025.103734.2060313797225120171.davem@davemloft.net>
References: <20171020234043.2629-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        john.fastabend@gmail.com
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41886 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751870AbdJYBhi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 21:37:38 -0400
In-Reply-To: <20171020234043.2629-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Fri, 20 Oct 2017 16:40:43 -0700

> Sock lock may be taken in the message timer function which is a
> problem since timers run in BH. Instead of timers use delayed_work.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Fixes: bbb03029a899 ("strparser: Generalize strparser")
> Signed-off-by: Tom Herbert <tom@quantonium.net>

Since this bug exists in 'net' I've applied this patch there.

Thanks.
