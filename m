From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 next] bonding: fix wq initialization for links
 created via netlink
Date: Fri, 21 Apr 2017 15:29:13 -0400 (EDT)
Message-ID: <20170421.152913.1790106808332321956.davem@davemloft.net>
References: <20170420194924.20829-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, andy@greyhouse.net, vfalico@gmail.com,
        nikolay@redhat.com, edumazet@google.com, joe@ovn.org,
        netdev@vger.kernel.org, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425168AbdDUT3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:29:21 -0400
In-Reply-To: <20170420194924.20829-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Thu, 20 Apr 2017 12:49:24 -0700

> From: Mahesh Bandewar <maheshb@google.com>
> 
> Earlier patch 4493b81bea ("bonding: initialize work-queues during
> creation of bond") moved the work-queue initialization from bond_open()
> to bond_create(). However this caused the link those are created using
> netlink 'create bond option' (ip link add bondX type bond); create the
> new trunk without initializing work-queues. Prior to the above mentioned
> change, ndo_open was in both paths and things worked correctly. The
> consequence is visible in the report shared by Joe Stringer -
> 
> I've noticed that this patch breaks bonding within namespaces if
> you're not careful to perform device cleanup correctly.
> 
> Here's my repro script, you can run on any net-next with this patch
> and you'll start seeing some weird behaviour:
 ...
> Fixes: 4493b81bea ("bonding: initialize work-queues during creation of bond")
> Reported-by: Joe Stringer <joe@ovn.org>
> Tested-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks.
