From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Add support of multicast static tree
Date: Sat, 19 Jan 2013 10:58:47 -0500 (EST)
Message-ID: <20130119.105847.1522596979256699554.davem@davemloft.net>
References: <1358528378-2110-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309Ab3ASP6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2013 10:58:49 -0500
In-Reply-To: <1358528378-2110-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 18 Jan 2013 17:59:36 +0100

> The goal of this serie is to add the support of proxy multicast, ie being able
> to build a static multicast tree. In other words, it adds the support of (*,G)
> mf[6]c entries.
> 
>  include/linux/mroute.h       |   2 +-
>  include/linux/mroute6.h      |   2 +-
>  include/uapi/linux/in6.h     |  15 ++----
>  include/uapi/linux/mroute.h  |   3 ++
>  include/uapi/linux/mroute6.h |   3 ++
>  net/ipv4/ipmr.c              | 118 +++++++++++++++++++++++++++++++++++-----
>  net/ipv6/ip6mr.c             | 126 ++++++++++++++++++++++++++++++++++++++-----
>  7 files changed, 230 insertions(+), 39 deletions(-)
> 
> Comments are welcome.

David, could you please review this series from Nicolas?

Thanks.
