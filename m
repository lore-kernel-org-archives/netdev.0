From: David Miller <davem@davemloft.net>
Subject: Re: [PATH net] ipv4: keep skb->dst around in presence of IP options
Date: Sat, 04 Feb 2017 19:43:02 -0500 (EST)
Message-ID: <20170204.194302.745228215982323493.davem@davemloft.net>
References: <1486235812.21871.145.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com, dvyukov@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56066 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751239AbdBEAnE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 19:43:04 -0500
In-Reply-To: <1486235812.21871.145.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 04 Feb 2017 11:16:52 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey Konovalov got crashes in __ip_options_echo() when a NULL skb->dst
> is accessed.
> 
> ipv4_pktinfo_prepare() should not drop the dst if (evil) IP options
> are present.
> 
> We could refine the test to the presence of ts_needtime or srr,
> but IP options are not often used, so let's be conservative.
> 
> Thanks to syzkaller team for finding this bug.
> 
> Fixes: d826eb14ecef ("ipv4: PKTINFO doesnt need dst reference")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks.
