From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Initialize the neighbour pointer of
 rt6_info on allocation
Date: Thu, 05 Jul 2012 14:21:25 -0700 (PDT)
Message-ID: <20120705.142125.249880960682842623.davem@davemloft.net>
References: <20120705131828.GE1869@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286Ab2GEVV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 17:21:27 -0400
In-Reply-To: <20120705131828.GE1869@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 5 Jul 2012 15:18:28 +0200

> git commit 97cac082 (ipv6: Store route neighbour in rt6_info struct)
> added a neighbour pointer to rt6_info. Currently we don't initialize
> this pointer at allocation time. We assume this pointer to be valid
> if it is not a null pointer, so initialize it on allocation.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied, but as Eric said we need to find a way to avoid having to
make changes like this every time we simply want to add a struct
member to rt6_info.
