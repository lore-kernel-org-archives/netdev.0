From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.4-stable] ipv6: reallocate addrconf router for ipv6
 address when lo, device up
Date: Thu, 24 Jul 2014 21:08:39 -0700 (PDT)
Message-ID: <20140724.210839.866750629795894870.davem@davemloft.net>
References: <53A233D9.8070202@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57775 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968AbaGYEIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 00:08:43 -0400
In-Reply-To: <53A233D9.8070202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chenweilong <chenweilong@huawei.com>
Date: Thu, 19 Jun 2014 08:50:33 +0800

> Please queue this for 3.4 stable kernel.
 ...
> +					dst_release(sp_ifa->rt);

dst_release() does not take a "struct rt6_info *", and therefore
the compile warns when you try to compile this.

For something like -stable, we should be as conservative as possible,
I expect at a minimum that you look at the build for warnings added by
your change.
