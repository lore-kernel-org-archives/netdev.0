From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udp6: set rx_dst_cookie on rx_dst updates
Date: Fri, 25 Aug 2017 20:10:03 -0700 (PDT)
Message-ID: <20170825.201003.262344560300570739.davem@davemloft.net>
References: <9e52c29f4bd47d591cdc7bf6c3a88b2fc57e4422.1503664112.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, subashab@codeaurora.org,
        hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHZDKE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 23:10:04 -0400
In-Reply-To: <9e52c29f4bd47d591cdc7bf6c3a88b2fc57e4422.1503664112.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 25 Aug 2017 14:31:01 +0200

> Currently, in the udp6 code, the dst cookie is not initialized/updated
> concurrently with the RX dst used by early demux.
> 
> As a result, the dst_check() in the early_demux path always fails,
> the rx dst cache is always invalidated, and we can't really
> leverage significant gain from the demux lookup.
> 
> Fix it adding udp6 specific variant of sk_rx_dst_set() and use it
> to set the dst cookie when the dst entry is really changed.
> 
> The issue is there since the introduction of early demux for ipv6.
> 
> Fixes: 5425077d73e0 ("net: ipv6: Add early demux handler for UDP unicast")
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied and queued up for -stable, thanks.
