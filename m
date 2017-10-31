From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipv6: Implement limits on Hop-by-Hop and
 Destination options
Date: Tue, 31 Oct 2017 11:10:26 +0900 (KST)
Message-ID: <20171031.111026.1763034451245817288.davem@davemloft.net>
References: <20171030211600.6491-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rohit@quantonium.net
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50762 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751871AbdJaCKa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 22:10:30 -0400
In-Reply-To: <20171030211600.6491-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Mon, 30 Oct 2017 14:16:00 -0700

> I wrote a quick test program that floods a whole bunch of these
> packets to a host and sure enough there is substantial time spent
> in ip6_parse_tlv.
 ...
>   25.38%  [kernel]                    [k] __fib6_clean_all
>   21.63%  [kernel]                    [k] ip6_parse_tlv

Yet the routing code still dominates the cost.
