From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net v2 0/2] bonding: fix arp_validate desync state &
 race
Date: Wed, 11 Sep 2013 15:55:50 -0400 (EDT)
Message-ID: <20130911.155550.1090007387355030571.davem@davemloft.net>
References: <1378504826-18855-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753710Ab3IKTzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 15:55:52 -0400
In-Reply-To: <1378504826-18855-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Sat,  7 Sep 2013 00:00:24 +0200

> Hello all,
> These two patches aim to fix the possible de-sync state which the bond
> can enter if we have arp_validate without arp_interval or the other way
> around. They also fix a race condition between arp_validate setting and
> mode changing.
> 
> Patch 01 - fixes the race condition between store_arp_validate and bond
> mode change by using rtnl for sync
> Patch 02 - fixes the possible de-sync state by setting/unsetting recv_probe
> if arp_interval is set/unset and also if arp_validate is set/unset
> 
> v2: Fix the mode check in store_arp_validate

Series applied, thank you.
