From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: properly prevent temp_prefered_lft sysctl race
Date: Thu, 20 Oct 2016 14:29:29 -0400 (EDT)
Message-ID: <20161020.142929.1228552177893783734.davem@davemloft.net>
References: <20161019131636.zhusbqh63qlbq5vy@dwarf.suse.cz>
        <20161019.145816.259194714319437266.davem@davemloft.net>
        <20161020102926.ysgqdjghmvc573s4@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        kbuild-all@01.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933076AbcJTS3g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:29:36 -0400
In-Reply-To: <20161020102926.ysgqdjghmvc573s4@dwarf.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Thu, 20 Oct 2016 12:29:26 +0200

> The check for an underflow of tmp_prefered_lft is always false
> because tmp_prefered_lft is unsigned. The intention of the check
> was to guard against racing with an update of the
> temp_prefered_lft sysctl, potentially resulting in an underflow.
> 
> As suggested by David Miller, the best way to prevent the race is
> by reading the sysctl variable using READ_ONCE.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> Reported-by: Julia Lawall <julia.lawall@lip6.fr>
> Fixes: 76506a986dc3 ("IPv6: fix DESYNC_FACTOR")

Applied, thanks Jiri.
