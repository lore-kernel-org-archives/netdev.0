From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: change skb->mac_header when Generic XDP calls
 adjust_head
Date: Wed, 20 Sep 2017 15:45:03 -0700 (PDT)
Message-ID: <20170920.154503.1584308233169563722.davem@davemloft.net>
References: <394385d4-796a-9ada-8f01-53a52d73a418@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40922 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751793AbdITWpE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 18:45:04 -0400
In-Reply-To: <394385d4-796a-9ada-8f01-53a52d73a418@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 19 Sep 2017 18:45:56 +0100

> Since XDP's view of the packet includes the MAC header, moving the start-
>  of-packet with bpf_xdp_adjust_head needs to also update the offset of the
>  MAC header (which is relative to skb->head, not to the skb->data that was
>  changed).
> Without this, tcpdump sees packets starting from the old MAC header rather
>  than the new one, at least in my tests on the loopback device.
> 
> Fixes: b5cdae3291f7 ("net: Generic XDP")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied and queued up for -stable, thanks Edward.
