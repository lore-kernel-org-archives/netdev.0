From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: seg6_genl_set_tunsrc() must check kmemdup()
 return value
Date: Fri, 20 Jan 2017 11:09:48 -0500 (EST)
Message-ID: <20170120.110948.494522496195320383.davem@davemloft.net>
References: <1484927862.16328.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.lebrun@uclouvain.be
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60588 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752373AbdATQJu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:09:50 -0500
In-Reply-To: <1484927862.16328.123.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Jan 2017 07:57:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> seg6_genl_get_tunsrc() and set_tun_src() do not handle tun_src being
> possibly NULL, so we must check kmemdup() return value and abort if
> it is NULL
> 
> Fixes: 915d7e5e5930 ("ipv6: sr: add code base for control plane support of SR-IPv6")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
