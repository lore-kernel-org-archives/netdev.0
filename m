From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] bonding: struct bonding cleanup and MAC
 set fixes
Date: Thu, 27 Jun 2013 22:51:16 -0700 (PDT)
Message-ID: <20130627.225116.236409010811785653.davem@davemloft.net>
References: <1372259619-32430-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab3F1FvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 01:51:17 -0400
In-Reply-To: <1372259619-32430-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Wed, 26 Jun 2013 17:13:36 +0200

> This patchset removes some unnecessary struct bonding members. It also
> fixes MAC setting inconsistencies (i.e. if a bond's MAC is set after
> creation but prior to enslaving, it is lost and the first slave's MAC is
> cloned again). Before these patches the only way to keep a user-defined MAC
> is either to set it after enslaving or to create the bond with that MAC.
> Patch 01 - removes setup_by_slave member
> Patch 02 - removes dev_addr_from_first member and does the MAC fixing
> Patch 03 - introduces the use of NET_ADDR_STOLEN when a MAC is cloned

These cleanups seem pretty reasonabl, all applied.

And yes I agree that those 3 pr_debug()'s in bond_set_dev_addr() should
be condensed into just one.  Feel free to send a patch which does that.

Thanks.
