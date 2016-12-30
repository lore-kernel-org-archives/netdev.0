From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: dev_weight: TX/RX orthogonality
Date: Thu, 29 Dec 2016 20:16:47 -0500 (EST)
Message-ID: <20161229.201647.324176080385260025.davem@davemloft.net>
References: <20161229.144555.1740958763290967121.davem@davemloft.net>
        <1483043841-10016-1-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, fw@strlen.de,
        edumazet@google.com, daniel@iogearbox.net
To: matthias.tafelmeier@gmx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbcL3BQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 20:16:51 -0500
In-Reply-To: <1483043841-10016-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Date: Thu, 29 Dec 2016 21:37:21 +0100

> Oftenly, introducing side effects on packet processing on the other half
> of the stack by adjusting one of TX/RX via sysctl is not desirable.
> There are cases of demand for asymmetric, orthogonal configurability.
> 
> This holds true especially for nodes where RPS for RFS usage on top is
> configured and therefore use the 'old dev_weight'. This is quite a
> common base configuration setup nowadays, even with NICs of superior processing
> support (e.g. aRFS).
> 
> A good example use case are nodes acting as noSQL data bases with a
> large number of tiny requests and rather fewer but large packets as responses.
> It's affordable to have large budget and rx dev_weights for the
> requests. But as a side effect having this large a number on TX
> processed in one run can overwhelm drivers.
> 
> This patch therefore introduces an independent configurability via sysctl to
> userland.
> 
> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>

Much better, applied, thanks.
