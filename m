From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: initialize rcv_mss to TCP_MIN_MSS instead of 0
Date: Sun, 21 May 2017 13:25:47 -0400 (EDT)
Message-ID: <20170521.132547.2153130831461643500.davem@davemloft.net>
References: <20170518182233.100933-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
        edumazet@google.com
To: weiwan@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45000 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdEURZt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:25:49 -0400
In-Reply-To: <20170518182233.100933-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>
Date: Thu, 18 May 2017 11:22:33 -0700

> From: Wei Wang <weiwan@google.com>
> 
> When tcp_disconnect() is called, inet_csk_delack_init() sets
> icsk->icsk_ack.rcv_mss to 0.
> This could potentially cause tcp_recvmsg() => tcp_cleanup_rbuf() =>
> __tcp_select_window() call path to have division by 0 issue.
> So this patch initializes rcv_mss to TCP_MIN_MSS instead of 0.
> 
> Reported-by: Andrey Konovalov  <andreyknvl@google.com>
> Signed-off-by: Wei Wang <weiwan@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks.
