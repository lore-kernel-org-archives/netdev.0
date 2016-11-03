From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: do not send reset to already closed sockets
Date: Thu, 03 Nov 2016 16:19:41 -0400 (EDT)
Message-ID: <20161103.161941.367902189230382386.davem@davemloft.net>
References: <CAAeHK+zBgPzp9KBCJb7_Q2Nm3n+t5HeuFwEFCDDc7cw234nREA@mail.gmail.com>
        <1478135064.7065.409.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org,
        netdev@vger.kernel.org, syzkaller@googlegroups.com, kcc@google.com,
        glider@google.com, edumazet@google.com, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756184AbcKCUTr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:19:47 -0400
In-Reply-To: <1478135064.7065.409.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 18:04:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey reported following warning while fuzzing with syzkaller
> 
> WARNING: CPU: 1 PID: 21072 at net/dccp/proto.c:83 dccp_set_state+0x229/0x290
> Kernel panic - not syncing: panic_on_warn set ...
 ...
> Fix this the same way we did for TCP in commit 565b7b2d2e63
> ("tcp: do not send reset to already closed sockets")
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable.
