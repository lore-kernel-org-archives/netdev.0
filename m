From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: clear saved_syn in tcp_disconnect()
Date: Sun, 09 Apr 2017 18:28:17 -0700 (PDT)
Message-ID: <20170409.182817.1110259190577384492.davem@davemloft.net>
References: <1491664053.10124.92.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34768 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750988AbdDJB2S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 21:28:18 -0400
In-Reply-To: <1491664053.10124.92.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 08 Apr 2017 08:07:33 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In the (very unlikely) case a passive socket becomes a listener,
> we do not want to duplicate its saved SYN headers.
> 
> This would lead to double frees, use after free, and please hackers and
> various fuzzers 
> 
> Tested:
 ...
> Fixes: cd8ae85299d5 ("tcp: provide SYN headers for passive connections")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
