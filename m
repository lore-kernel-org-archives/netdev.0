From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix signedness of tmp_prefered_lft underflow
 check
Date: Tue, 18 Oct 2016 14:25:25 -0400 (EDT)
Message-ID: <20161018.142525.1262217492229127435.davem@davemloft.net>
References: <alpine.DEB.2.20.1610151945380.9280@hadrien>
        <20161018150154.4tpivtvxygp7kjpd@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        kbuild-all@01.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753955AbcJRSZ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:25:27 -0400
In-Reply-To: <20161018150154.4tpivtvxygp7kjpd@dwarf.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Tue, 18 Oct 2016 17:01:54 +0200

> Commit 76506a986dc31394fd1f2741db037d29c7e57843 (IPv6: fix
> DESYNC_FACTOR) introduced a buggy check for underflow of
> tmp_prefered_lft. tmp_prefered_lft is unsigned, so the condition
> is always false.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> Reported-by: Julia Lawall <julia.lawall@lip6.fr>
> Fixes: 76506a986dc3 ("IPv6: fix DESYNC_FACTOR")

Does the check make any sense at all?  I'd say just remove it.
