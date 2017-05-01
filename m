From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix access to sk->sk_state in tcp_poll()
Date: Sun, 30 Apr 2017 22:25:11 -0400 (EDT)
Message-ID: <20170430.222511.1580121304843279513.davem@davemloft.net>
References: <0a1710138c3e55c388a52dba817b2d1b1996c899.1493226034.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, weiwan@google.com, netdev@vger.kernel.org
To: dcaratti@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54136 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642288AbdEACZO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:25:14 -0400
In-Reply-To: <0a1710138c3e55c388a52dba817b2d1b1996c899.1493226034.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>
Date: Wed, 26 Apr 2017 19:07:35 +0200

> avoid direct access to sk->sk_state when tcp_poll() is called on a socket
> using active TCP fastopen with deferred connect. Use local variable
> 'state', which stores the result of sk_state_load(), like it was done in
> commit 00fd38d938db ("tcp: ensure proper barriers in lockless contexts").
> 
> Fixes: 19f6d3f3c842 ("net/tcp-fastopen: Add new API support")
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Applied.
