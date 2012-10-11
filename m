From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix route mark sparse warning
Date: Wed, 10 Oct 2012 22:55:19 -0400 (EDT)
Message-ID: <20121010.225519.1146598383921356809.davem@davemloft.net>
References: <20121010112725.57a6f4a6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956Ab2JKCzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 22:55:21 -0400
In-Reply-To: <20121010112725.57a6f4a6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 10 Oct 2012 11:27:25 -0700

> Sparse complains about RTA_MARK which is should be host order according
> to include file and usage in iproute.
> 
> net/ipv4/route.c:2223:46: warning: incorrect type in argument 3 (different base types)
> net/ipv4/route.c:2223:46:    expected restricted __be32 [usertype] value
> net/ipv4/route.c:2223:46:    got unsigned int [unsigned] [usertype] flowic_mark
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
