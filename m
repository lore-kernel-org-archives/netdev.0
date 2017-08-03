From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: remove extra POLL_OUT added for finished
 active connect()
Date: Thu, 03 Aug 2017 09:31:05 -0700 (PDT)
Message-ID: <20170803.093105.1654064524790607267.davem@davemloft.net>
References: <20170802195958.21383-1-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, edumazet@google.com,
        ycheng@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45220 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdHCQbG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:31:06 -0400
In-Reply-To: <20170802195958.21383-1-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Wed,  2 Aug 2017 15:59:58 -0400

> Commit 45f119bf936b ("tcp: remove header prediction") introduced a
> minor bug: the sk_state_change() and sk_wake_async() notifications for
> a completed active connection happen twice: once in this new spot
> inside tcp_finish_connect() and once in the existing code in
> tcp_rcv_synsent_state_process() immediately after it calls
> tcp_finish_connect(). This commit remoes the duplicate POLL_OUT
> notifications.
> 
> Fixes: 45f119bf936b ("tcp: remove header prediction")
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied, thanks.
