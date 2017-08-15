From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: purge write queue in dccp_destroy_sock()
Date: Mon, 14 Aug 2017 22:29:12 -0700 (PDT)
Message-ID: <20170814.222912.1991335275723485614.davem@davemloft.net>
References: <1502745025.4936.34.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50740 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdHOF3M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 01:29:12 -0400
In-Reply-To: <1502745025.4936.34.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Aug 2017 14:10:25 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller reported that DCCP could have a non empty
> write queue at dismantle time.
> 
> WARNING: CPU: 1 PID: 2953 at net/core/stream.c:199 sk_stream_kill_queues+0x3ce/0x520 net/core/stream.c:199
> Kernel panic - not syncing: panic_on_warn set ...
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks.
