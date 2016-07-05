From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix decnet rtnexthop parsing
Date: Tue, 05 Jul 2016 14:08:58 -0700 (PDT)
Message-ID: <20160705.140858.1158586328624337181.davem@davemloft.net>
References: <1467745973-22340-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: vegard.nossum@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbcGEVJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 17:09:01 -0400
In-Reply-To: <1467745973-22340-1-git-send-email-vegard.nossum@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vegard Nossum <vegard.nossum@oracle.com>
Date: Tue,  5 Jul 2016 21:12:53 +0200

> dn_fib_count_nhs() could enter an infinite loop if nhp->rtnh_len == 0
> (i.e. if userspace passes a malformed netlink message).
> 
> Let's use the helpers from net/nexthop.h which take care of all this
> stuff. We can do exactly the same as e.g. fib_count_nexthops() and
> fib_get_nhs() from net/ipv4/fib_semantics.c.
> 
> This fixes the softlockup for me.
> 
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Applied, thanks.
