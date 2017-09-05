From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] flow_dissector: Flow dissector fixes
Date: Tue, 05 Sep 2017 11:45:04 -0700 (PDT)
Message-ID: <20170905.114504.207582830119826554.davem@davemloft.net>
References: <20170901210412.2915-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        alex.popov@linux.com
To: tom@quantonium.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36802 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752129AbdIESpH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 14:45:07 -0400
In-Reply-To: <20170901210412.2915-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@quantonium.net>
Date: Fri,  1 Sep 2017 14:04:10 -0700

> This patch set fixes some basic issues with __skb_flow_dissect function.
> 
> Items addressed:
>   - Cleanup control flow in the function; in particular eliminate a
>     bunch of goto's and implement a simplified control flow model
>   - Add limits for number of encapsulations and headers that can be
>     dissected
> 
> v2:
>   - Simplify the logic for limits on flow dissection. Just set the
>     limit based on the number of headers the flow dissector can
>     processes. The accounted headers includes encapsulation headers,
>     extension headers, or other shim headers.
> 
> Tested:
> 
> Ran normal traffic, GUE, and VXLAN traffic.

Applied, thanks Tom.
