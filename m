From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] l2tp: socket lookup fixes for l2tp_ip and
 l2tp_ip6
Date: Sun, 01 Jan 2017 22:07:57 -0500 (EST)
Message-ID: <20170101.220757.1066333962240697447.davem@davemloft.net>
References: <cover.1483123297.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750709AbdABDH7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 22:07:59 -0500
In-Reply-To: <cover.1483123297.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 30 Dec 2016 19:48:17 +0100

> There are still some cases that aren't correctly handled in the socket
> lookup functions of l2tp_ip and l2tp_ip6. This series fixes lookups for
> connected sockets and for sockets bound to the IPv6 unspecified
> address.
> 
> bind() and connect() should now work as expected on IPPROTO_L2TP
> sockets. Extra features, like SO_REUSEADDR, remain unsupported.
> 
> The matching conditions in __l2tp_ip6_bind_lookup() and
> __l2tp_ip_bind_lookup() are getting hard to read. I've kept the single
> test approach to make the intend of the patches clear. I'll split the
> conditionals once these fixes reach net-next.

Series applied, thank you.
