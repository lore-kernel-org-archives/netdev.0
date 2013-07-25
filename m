From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: take rtnl_lock and mark mrt6 table as freed
 on namespace cleanup
Date: Wed, 24 Jul 2013 17:03:03 -0700 (PDT)
Message-ID: <20130724.170303.1643662786074096216.davem@davemloft.net>
References: <20130722214553.GF6538@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, srivatsa.bhat@linux.vnet.ibm.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab3GYADE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 20:03:04 -0400
In-Reply-To: <20130722214553.GF6538@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 22 Jul 2013 23:45:53 +0200

> Otherwise we end up dereferencing the already freed net->ipv6.mrt pointer
> which leads to a panic (from Srivatsa S. Bhat):
 ...
> Reported-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> Tested-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied and queued up for -stable, thanks!
