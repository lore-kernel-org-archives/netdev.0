From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] l2tp: fix some l2tp_tunnel_find() issues in
 l2tp_netlink
Date: Mon, 28 Aug 2017 11:35:16 -0700 (PDT)
Message-ID: <20170828.113516.2181846322329552747.davem@davemloft.net>
References: <cover.1503671776.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdH1SfR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 14:35:17 -0400
In-Reply-To: <cover.1503671776.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 25 Aug 2017 16:51:39 +0200

> Since l2tp_tunnel_find() doesn't take a reference on the tunnel it
> returns, its users are almost guaranteed to be racy.
> 
> This series defines l2tp_tunnel_get() which can be used as a safe
> replacement, and converts some of l2tp_tunnel_find() users in the
> l2tp_netlink module.
> 
> Other users often combine this issue with other more or less subtle
> races. They will be fixed incrementally in followup series.

Series applied, thank you.
