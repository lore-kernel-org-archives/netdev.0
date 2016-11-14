From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: fix sleeping for sk_wait_event()
Date: Mon, 14 Nov 2016 13:17:49 -0500 (EST)
Message-ID: <20161114.131749.117151077627113186.davem@davemloft.net>
References: <1478888450-16985-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        peterz@infradead.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935050AbcKNSRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 13:17:51 -0500
In-Reply-To: <1478888450-16985-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 11 Nov 2016 10:20:50 -0800

> Similar to commit 14135f30e33c ("inet: fix sleeping inside inet_wait_for_connect()"),
> sk_wait_event() needs to fix too, because release_sock() is blocking,
> it changes the process state back to running after sleep, which breaks
> the previous prepare_to_wait().
> 
> Switch to the new wait API.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
