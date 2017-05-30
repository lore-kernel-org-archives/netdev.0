From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/9] net: another round of extack handling
 for routing
Date: Tue, 30 May 2017 11:55:53 -0400 (EDT)
Message-ID: <20170530.115553.460294781540103319.davem@davemloft.net>
References: <20170527221933.57644-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52580 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750908AbdE3Pzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 11:55:55 -0400
In-Reply-To: <20170527221933.57644-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Sat, 27 May 2017 16:19:24 -0600

> This set focuses on passing extack through lwtunnel and MPLS with
> additional catches for IPv4 route add and minor cleanups in MPLS
> encountered passing the extack arg around.
> 
> v2
> - mindful of bloat adding duplicate messages
>   + refactored prefix and prefix length checks in ipv4's fib_table_insert
>     and fib_table_del
>   + refactored label check in mpls
> 
> - split mpls cleanups into 2 patches
>   + move nla_get_via up in af_mpls to avoid forward declaration

Series applied, thanks David.
