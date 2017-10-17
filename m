From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: export netdev_txq_to_tc to allow sch_mqprio to
 compile as module
Date: Tue, 17 Oct 2017 17:00:42 +0100 (WEST)
Message-ID: <20171017.170042.1711156550393094740.davem@davemloft.net>
References: <1508235010-4056-1-git-send-email-haustad@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, daniel@iogearbox.net,
        dsahern@gmail.com, alexander.h.duyck@intel.com, willemb@google.com,
        john.fastabend@gmail.com, me@tobin.cc,
        linux-kernel@vger.kernel.org, haustad@cisco.com,
        jesus.sanchez-palencia@intel.com
To: henrik@austad.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753368AbdJQQA6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 12:00:58 -0400
In-Reply-To: <1508235010-4056-1-git-send-email-haustad@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henrik Austad <henrik@austad.us>
Date: Tue, 17 Oct 2017 12:10:10 +0200

> In commit 32302902ff09 ("mqprio: Reserve last 32 classid values for HW
> traffic classes and misc IDs") sch_mqprio started using netdev_txq_to_tc
> to find the correct tc instead of dev->tc_to_txq[]
> 
> However, when mqprio is compiled as a module, it cannot resolve the
> symbol, leading to this error:
> 
>      ERROR: "netdev_txq_to_tc" [net/sched/sch_mqprio.ko] undefined!
> 
> This adds an EXPORT_SYMBOL() since the other user in the kernel
> (netif_set_xps_queue) is also EXPORT_SYMBOL() (and not _GPL) or in a
> sysfs-callback.
> 
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Cc: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Henrik Austad <haustad@cisco.com>

Applied, thanks.
