From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: recursive check rt->dst.from when call
 rt6_check_expired
Date: Wed, 19 Sep 2012 15:35:57 -0400 (EDT)
Message-ID: <20120919.153557.878111517154636053.davem@davemloft.net>
References: <1347602097-18034-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160Ab2ISTf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:35:59 -0400
In-Reply-To: <1347602097-18034-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 14 Sep 2012 13:54:57 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> If dst cache dst_a copies from dst_b, and dst_b copies from dst_c, check
> if dst_a is expired or not, we should not end with dst_a->dst.from, dst_b,
> we should check dst_c.
> 
> CC: Gao feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied, thanks.
