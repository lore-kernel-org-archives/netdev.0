From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: make TCP_INFO more consistent
Date: Mon, 09 Jan 2017 17:08:45 -0500 (EST)
Message-ID: <20170109.170845.2114320955926994265.davem@davemloft.net>
References: <1483986567.21472.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52514 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751830AbdAIWIr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 17:08:47 -0500
In-Reply-To: <1483986567.21472.10.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Jan 2017 10:29:27 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_get_info() has to lock the socket, so lets lock it
> for an extended critical section, so that various fields
> have consistent values.
> 
> This solves an annoying issue that some applications
> reported when multiple counters are updated during one
> particular rx/rx event, and TCP_INFO was called from
> another cpu.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
