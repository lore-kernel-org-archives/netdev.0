From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/3] ipip: fix sparse warnings in
 ipip_netlink_parms()
Date: Thu, 15 Nov 2012 13:56:48 -0500 (EST)
Message-ID: <20121115.135648.390876952744254628.davem@davemloft.net>
References: <1352985602.4497.31.camel@edumazet-glaptop>
	<1352988402-16950-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	fengguang.wu@intel.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46916 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1768687Ab2KOS4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 13:56:49 -0500
In-Reply-To: <1352988402-16950-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 15 Nov 2012 15:06:40 +0100

> This change fixes two sparse warnings triggered by casting the ip addresses
> from netlink messages in an u32 instead of be32. This change corrects that
> in order to resolve the sparse warnings.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
