From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net/tcp-fastopen: Add new userspace API
 support
Date: Wed, 25 Jan 2017 14:09:49 -0500 (EST)
Message-ID: <20170125.140949.1462062401464436228.davem@davemloft.net>
References: <20170123185922.48046-1-tracywwnj@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ycheng@google.com,
        weiwan@google.com
To: tracywwnj@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59714 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752207AbdAYTJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 14:09:51 -0500
In-Reply-To: <20170123185922.48046-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <tracywwnj@gmail.com>
Date: Mon, 23 Jan 2017 10:59:19 -0800

> The patch series is to add support for new userspace API for TCP fastopen
> sockets. 
> In the current code, user has to call sendto()/sendmsg() with special flag
> MSG_FASTOPEN for TCP fastopen sockets. This API is quite different from the
> normal TCP socket API and can be cumbersome for applications to make use
> fastopen sockets.
> So this new patch introduces a new way of using TCP fastopen sockets which
> is similar to normal TCP sockets with a new sockopt TCP_FASTOPEN_CONNECT.
> More details about it is described in the third patch.
> (First 2 patches are preparations for the third patch.)

Series applied.
