From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] l2tp: cleanup socket lookup code in
 l2tp_ip and l2tp_ip6
Date: Fri, 06 Jan 2017 22:19:13 -0500 (EST)
Message-ID: <20170106.221913.1150017479115532240.davem@davemloft.net>
References: <cover.1483727525.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbdAGDTP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 22:19:15 -0500
In-Reply-To: <cover.1483727525.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 6 Jan 2017 20:03:53 +0100

> First three patches remove redundant tests and add missing "const"
> qualifiers.
> 
> Fourth patch splits the conditionals found in __l2tp_ip*_bind_lookup(),
> to make these functions easier to review. In the process, I found that
> some corner cases were still not handled properly. So I've added the
> missing tests in this patch too, because they're pretty simple and the
> whole "if" statements are modified anyway.
> 
> I expect it to be easier to review this way. If not, I can split up
> patch #4, post the missing tests separately to -net, and later repost
> this series as pure cleanup. Just let me know.

Looks good to me, series applied, thanks.
