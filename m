From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] ipv6: sr: fix BUG due to headroom too
 small after SRH push
Date: Mon, 17 Apr 2017 15:34:21 -0400 (EDT)
Message-ID: <20170417.153421.626707285296729621.davem@davemloft.net>
References: <20170416102714.11508-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57418 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756627AbdDQTeX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:34:23 -0400
In-Reply-To: <20170416102714.11508-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Sun, 16 Apr 2017 12:27:14 +0200

> When a locally generated packet receives an SRH with two or more segments,
> the remaining headroom is too small to push an ethernet header. This patch
> ensures that the headroom is large enough after SRH push.
> 
> The BUG generated the following trace.
 ...
> Fixes: 19d5a26f5ef8de5dcb78799feaf404d717b1aac3 ("ipv6: sr: expand skb head only if necessary")
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied, thank you.
