From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tcp: check skb is non-NULL for exact match on
 lookups
Date: Thu, 03 Nov 2016 16:06:25 -0400 (EDT)
Message-ID: <20161103.160625.1817596298692975304.davem@davemloft.net>
References: <1478113705-16174-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andreyknvl@google.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42244 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756816AbcKCUG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 16:06:27 -0400
In-Reply-To: <1478113705-16174-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  2 Nov 2016 12:08:25 -0700

> Andrey reported the following error report while running the syzkaller
> fuzzer:
 ...
> MD5 has a code path that calls __inet_lookup_listener with a null skb,
> so inet{6}_exact_dif_match needs to check skb against null before pulling
> the flag.
> 
> Fixes: a04a480d4392 ("net: Require exact match for TCP socket lookups if
>        dif is l3mdev")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> Dave: commit a04a480d4392 was queued for stable, so this needs to follow it.

Applied and queued up for -stable, thanks.
