From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] uapi: define DIV_ROUND_UP for userland
Date: Thu, 03 Mar 2016 16:43:52 -0500 (EST)
Message-ID: <20160303.164352.1296057971694454944.davem@davemloft.net>
References: <1456846141.3098.155.camel@decadent.org.uk>
	<1456850464-23003-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk, kan.liang@intel.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757773AbcCCVny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 16:43:54 -0500
In-Reply-To: <1456850464-23003-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  1 Mar 2016 17:41:03 +0100

> DIV_ROUND_UP is defined in linux/kernel.h only for the kernel.
> When ethtool.h is included by a userland app, we got the following error:
> 
> include/linux/ethtool.h:1218:8: error: variably modified 'queue_mask' at file scope
>   __u32 queue_mask[DIV_ROUND_UP(MAX_NUM_QUEUE, 32)];
>         ^
> 
> Let's add a common definition in uapi and use it everywhere.
> 
> Fixes: ac2c7ad0e5d6 ("net/ethtool: introduce a new ioctl for per queue setting")
> CC: Kan Liang <kan.liang@intel.com>
> Suggested-by: Ben Hutchings <ben@decadent.org.uk>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
