From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: skb_flow_get_be16() can be static
Date: Tue, 10 Jan 2017 13:31:35 -0500 (EST)
Message-ID: <20170110.133135.1288355336758425739.davem@davemloft.net>
References: <1483989481.21472.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935598AbdAJSbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:31:53 -0500
In-Reply-To: <1483989481.21472.16.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 09 Jan 2017 11:18:01 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Removes following sparse complain :
> 
> net/core/flow_dissector.c:70:8: warning: symbol 'skb_flow_get_be16'
> was not declared. Should it be static?
> 
> Fixes: 972d3876faa8 ("flow dissector: ICMP support")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
