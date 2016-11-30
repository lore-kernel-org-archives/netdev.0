From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/dccp: fix use-after-free in dccp_invalid_packet
Date: Tue, 29 Nov 2016 20:38:01 -0500 (EST)
Message-ID: <20161129.203801.926114791600466509.davem@davemloft.net>
References: <CAAeHK+zYNyuFUU+w0rLWvvZqivSedrqMpS5UYt=c4uqajS_Stw@mail.gmail.com>
        <1480343209.18162.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        dvyukov@google.com, kcc@google.com, edumazet@google.com,
        syzkaller@googlegroups.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39388 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754020AbcK3BiO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 20:38:14 -0500
In-Reply-To: <1480343209.18162.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2016 06:26:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> pskb_may_pull() can reallocate skb->head, we need to reload dh pointer
> in dccp_invalid_packet() or risk use after free.
> 
> Bug found by Andrey Konovalov using syzkaller.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks Eric.
