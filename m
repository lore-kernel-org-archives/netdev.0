From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] bonding: race and inconsistency fixes
Date: Sun, 19 May 2013 23:26:19 -0700 (PDT)
Message-ID: <20130519.232619.104616236191299455.davem@davemloft.net>
References: <1368875911-4952-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457Ab3ETG0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 02:26:22 -0400
In-Reply-To: <1368875911-4952-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Sat, 18 May 2013 13:18:27 +0200

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
> 
>  v2 is to address a minor style fix, to make the wrapper
>  global and move it to bond_3ad.c, and also to fix the naming of the
>  functions, all in patch 4/4.

Series applied, thanks.
