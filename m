From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: fix __percpu annotation
Date: Sun, 01 Oct 2017 03:58:30 +0100 (WEST)
Message-ID: <20171001.035830.1241812496925979772.davem@davemloft.net>
References: <1e69021734ef43406df65571b9fa97884831825d.1506613995.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gfree.wind@vip.163.com, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdJAC6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 22:58:32 -0400
In-Reply-To: <1e69021734ef43406df65571b9fa97884831825d.1506613995.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 28 Sep 2017 17:57:58 +0200

> Move sparse annotation right after pointer type.
> 
> Fixes sparse warning:
>     drivers/net/ppp/ppp_generic.c:1422:13: warning: incorrect type in initializer (different address spaces)
>     drivers/net/ppp/ppp_generic.c:1422:13:    expected void const [noderef] <asn:3>*__vpp_verify
>     drivers/net/ppp/ppp_generic.c:1422:13:    got int *<noident>
>     ...
> 
> Fixes: e5dadc65f9e0 ("ppp: Fix false xmit recursion detect with two ppp devices")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied, thank you.
