From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sr: fix double free of skb after handling
 invalid SRH
Date: Fri, 21 Apr 2017 13:17:17 -0400 (EDT)
Message-ID: <20170421.131717.1896879335523801049.davem@davemloft.net>
References: <20170419141019.8193-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37172 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424540AbdDUTMb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:12:31 -0400
In-Reply-To: <20170419141019.8193-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Wed, 19 Apr 2017 16:10:19 +0200

> The icmpv6_param_prob() function already does a kfree_skb(),
> this patch removes the duplicate one.
> 
> Fixes: 1ababeba4a21f3dba3da3523c670b207fb2feb62 ("ipv6: implement dataplane support for rthdr type 4 (Segment Routing Header)")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>

Applied and queued up for -stable, thanks.
