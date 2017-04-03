From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sock: correctly test SOCK_TIMESTAMP in
 sock_recv_ts_and_drops()
Date: Sun, 02 Apr 2017 19:35:10 -0700 (PDT)
Message-ID: <20170402.193510.454489020501586508.davem@davemloft.net>
References: <f29d595f4a72d77730447be2a7c5f243fad47751.1490875313.git.pabeni@redhat.com>
        <20170330.202924.1023519735753552178.davem@davemloft.net>
        <1490997565.8750.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdDCCfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 22:35:12 -0400
In-Reply-To: <1490997565.8750.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 31 Mar 2017 14:59:25 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems the code does not match the intent.
> 
> This broke packetdrill, and probably other programs.
> 
> Fixes: 6c7c98bad488 ("sock: avoid dirtying sk_stamp, if possible")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
