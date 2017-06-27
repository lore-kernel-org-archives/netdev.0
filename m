From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: prevent sign extension in dev_get_stats()
Date: Tue, 27 Jun 2017 14:51:31 -0400 (EDT)
Message-ID: <20170627.145131.1627364252295077432.davem@davemloft.net>
References: <1497054551.736.99.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170610.161335.734544822657172006.davem@davemloft.net>
        <1498572140.736.115.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dheidler@suse.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44112 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752637AbdF0Svc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 14:51:32 -0400
In-Reply-To: <1498572140.736.115.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Jun 2017 07:02:20 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Similar to the fix provided by Dominik Heidler in commit
> 9b3dc0a17d73 ("l2tp: cast l2tp traffic counter to unsigned")
> we need to take care of 32bit kernels in dev_get_stats().
> 
> When using atomic_long_read(), we add a 'long' to u64 and
> might misinterpret high order bit, unless we cast to unsigned.
> 
> Fixes: caf586e5f23ce ("net: add a core netdev->rx_dropped counter")
> Fixes: 015f0688f57ca ("net: net: add a core netdev->tx_dropped counter")
> Fixes: 6e7333d315a76 ("net: add rx_nohandler stat counter")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jarod Wilson <jarod@redhat.com>

Applied and queued up for -stable, thanks.
