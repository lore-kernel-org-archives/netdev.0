From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ndisc: Do not try to update "updated" time if
 neighbour has already gone.
Date: Mon, 21 Jan 2013 15:42:05 -0500 (EST)
Message-ID: <20130121.154205.1471846327319951833.davem@davemloft.net>
References: <50FD9DFA.6090001@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab3AUUmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 15:42:07 -0500
In-Reply-To: <50FD9DFA.6090001@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 22 Jan 2013 04:58:50 +0900

> Commit 2152caea ("ipv6: Do not depend on rt->n in rt6_probe().")
> introduce a bug to try to update "updated" time in neighbour
> structure.
> Update the "updated" time only if neighbour is available.
> 
> Bug was found by Dan Carpenter <dan.carpenter@oracle.com>
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
