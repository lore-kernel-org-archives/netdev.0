From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: recompute reachabletime before returning from
 neigh_periodic_work()
Date: Thu, 27 Feb 2014 18:22:29 -0500 (EST)
Message-ID: <20140227.182229.1062454622900632661.davem@davemloft.net>
References: <530F0201.2040303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbaB0XWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 18:22:31 -0500
In-Reply-To: <530F0201.2040303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Thu, 27 Feb 2014 17:14:41 +0800

> If the neigh table's entries is less than gc_thresh1, the function
> will return directly, and the reachabletime will not be recompute,
> so the reachabletime can be guessed.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

It looks like this bug was unintentionally introduced by:

commit 2724680bceee94eac391552863771af105a7355c
Author: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date:   Tue Jan 22 05:20:05 2013 +0000

    neigh: Keep neighbour cache entries if number of them is small enough.

Applied and queued up for -stable, thanks!
