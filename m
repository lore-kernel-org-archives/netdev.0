From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: remove br_dev_set_multicast_list
Date: Fri, 01 Apr 2016 14:43:19 -0400 (EDT)
Message-ID: <20160401.144319.1278231945562755336.davem@davemloft.net>
References: <1459498570-30664-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808AbcDASnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 14:43:21 -0400
In-Reply-To: <1459498570-30664-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri,  1 Apr 2016 16:16:10 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> remove br_dev_set_multicast_list which does nothing
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

This will break SIOCADDMULTI et al. on the bridge, see net/core/dev.c
which checks whether this ndo OP is NULL or not.

Please sufficiently grep the source tree on how an ndo operation is
used before making changes like this.

Thanks.
