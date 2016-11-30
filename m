From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] GSO: Reload iph after pskb_may_pull
Date: Tue, 29 Nov 2016 20:46:31 -0500 (EST)
Message-ID: <20161129.204631.2015697427915386486.davem@davemloft.net>
References: <20161128153658.GB4778@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, aduyck@mirantis.com, andreyknvl@google.com,
        netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39636 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcK3Bqc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 20:46:32 -0500
In-Reply-To: <20161128153658.GB4778@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@kernel.org>
Date: Mon, 28 Nov 2016 12:36:58 -0300

> As it may get stale and lead to use after free.
> 
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Alexander Duyck <aduyck@mirantis.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Fixes: cbc53e08a793 ("GSO: Add GSO type for fixed IPv4 ID")
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied and queued up for -stable, thanks Arnaldo!
