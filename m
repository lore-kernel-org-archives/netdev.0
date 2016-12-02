From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: avoid signed overflows for
 SO_{SND|RCV}BUFFORCE
Date: Fri, 02 Dec 2016 14:10:41 -0500 (EST)
Message-ID: <20161202.141041.912805364993627369.davem@davemloft.net>
References: <1480700693.18162.378.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39170 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750842AbcLBTKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 14:10:43 -0500
In-Reply-To: <1480700693.18162.378.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Dec 2016 09:44:53 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> CAP_NET_ADMIN users should not be allowed to set negative
> sk_sndbuf or sk_rcvbuf values, as it can lead to various memory
> corruptions, crashes, OOM...
> 
> Note that before commit 82981930125a ("net: cleanups in
> sock_setsockopt()"), the bug was even more serious, since SO_SNDBUF
> and SO_RCVBUF were vulnerable.
> 
> This needs to be backported to all known linux kernels.
> 
> Again, many thanks to syzkaller team for discovering this gem.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks Eric.
