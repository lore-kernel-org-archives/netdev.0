From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] tcp: reset sk_rx_dst in tcp_disconnect()
Date: Sun, 25 Jun 2017 12:23:35 -0400 (EDT)
Message-ID: <20170625.122335.2262782871024243094.davem@davemloft.net>
References: <1498373430-24807-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avagin@gmail.com, kaiwen.xu@hulu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40854 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751142AbdFYQXh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 12:23:37 -0400
In-Reply-To: <1498373430-24807-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sat, 24 Jun 2017 23:50:30 -0700

> We have to reset the sk->sk_rx_dst when we disconnect a TCP
> connection, because otherwise when we re-connect it this
> dst reference is simply overridden in tcp_finish_connect().
> 
> This fixes a dst leak which leads to a loopback dev refcnt
> leak. It is a long-standing bug, Kevin reported a very similar
> (if not same) bug before. Thanks to Andrei for providing such
> a reliable reproducer which greatly narrows down the problem.
> 
> Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")
> Reported-by: Andrei Vagin <avagin@gmail.com>
> Reported-by: Kevin Xu <kaiwen.xu@hulu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks!
