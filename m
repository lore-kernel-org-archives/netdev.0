From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix keepalive code vs TCP_FASTOPEN_CONNECT
Date: Thu, 03 Aug 2017 09:35:43 -0700 (PDT)
Message-ID: <20170803.093543.1047513143422057166.davem@davemloft.net>
References: <1501740646.25002.31.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weiwan@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdHCQfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 12:35:44 -0400
In-Reply-To: <1501740646.25002.31.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Aug 2017 23:10:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller was able to trigger a divide by 0 in TCP stack [1]
> 
> Issue here is that keepalive timer needs to be updated to not attempt
> to send a probe if the connection setup was deferred using
> TCP_FASTOPEN_CONNECT socket option added in linux-4.11
...
> Fixes: 19f6d3f3c842 ("net/tcp-fastopen: Add new API support")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks!
