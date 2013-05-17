From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] bonding: race and inconsistency fixes
Date: Fri, 17 May 2013 01:30:57 -0700 (PDT)
Message-ID: <20130517.013057.1998803722045738861.davem@davemloft.net>
References: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753577Ab3EQIa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:30:58 -0400
In-Reply-To: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed, 15 May 2013 14:32:38 +0200

> Hello,
>  In patch 1/4 a race condition while changing the bonding mode through
>  sysfs is fixed. Since no synchronization method is used it can race
>  with different functions resulting in different impacts. RTNL is used
>  to sync with the most important and dangerous events.
>  Patch 2/4 is trivial and improves the debugging output by changing %x
>  format to %pI4 for IPv4 addresses in a few pr_debug() calls.
>  Patch 3/4 fixes an inconsistent arp_targets state where we have 0 entry
>  between (or in the beginning) the valid entries that were obtained which
>  is hard to diagnose otherwise.
>  Patch 4/4 fixes multiple instances of a race condition which is because of
>  calls to bond_3ad_get_active_agg_info without any locking, and since it 
>  traverses the slave list this can easily result in NULL ptr dereference or
>  use of freed memory.

Can a bonding expert please review this series?

Thanks.
