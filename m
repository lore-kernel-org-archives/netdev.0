From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: rtnetlink: fdb dflt dump must set idx
 used for cb->arg[0]
Date: Fri, 29 Mar 2013 15:27:04 -0400 (EDT)
Message-ID: <20130329.152704.895903622717759647.davem@davemloft.net>
References: <20130329181831.9902.70451.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56325 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756282Ab3C2T1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:27:06 -0400
In-Reply-To: <20130329181831.9902.70451.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 29 Mar 2013 11:18:37 -0700

> In rtnl_fdb_dump() when the fdb_dump ndo op is not populated
> we never set the idx value so that cb->arg[0] is always 0.
> Resulting in a endless loop of messages.
> 
> Introduced with this commit,
> 
> commit 090096bf3db1c281ddd034573260045888a68fea
> Author: Vlad Yasevich <vyasevic@redhat.com>
> Date:   Wed Mar 6 15:39:42 2013 +0000
> 
>     net: generic fdb support for drivers without ndo_fdb_<op>
> 
> CC: Vlad Yasevich <vyasevic@redhat.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks John.
