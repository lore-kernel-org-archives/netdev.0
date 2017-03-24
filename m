From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Performances improvement for IPv6 Segment
 Routing
Date: Fri, 24 Mar 2017 14:48:05 -0700 (PDT)
Message-ID: <20170324.144805.1899893937234644395.davem@davemloft.net>
References: <20170324094627.16796-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933123AbdCXVsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:48:06 -0400
In-Reply-To: <20170324094627.16796-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Fri, 24 Mar 2017 10:46:25 +0100

> This patch series improves the performances of IPv6 SR by optimizing skb head
> reallocation and extending the use of dst_cache. The overall performances improve
> by 35%.

Series applied, thanks.

I think you should make SEG6_IPTUNNEL select DST_CACHE and then remove all of
these ugly ifdefs.

Thanks.
