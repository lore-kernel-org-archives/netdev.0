From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] qdisc: adjustments for API allowing skb
 list xmits
Date: Tue, 02 Sep 2014 14:06:37 -0700 (PDT)
Message-ID: <20140902.140637.1575167236785057277.davem@davemloft.net>
References: <20140902143254.1918.8419.stgit@dragon>
	<20140902143524.1918.70967.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, hannes@stressinduktion.org,
	dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58667 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164AbaIBVGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 17:06:38 -0400
In-Reply-To: <20140902143524.1918.70967.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 02 Sep 2014 16:35:33 +0200

> Minor adjustments for merge commit 53fda7f7f9e (Merge branch 'xmit_list')
> that allows us to work with a list of SKBs.
> 
> Update code doc to function sch_direct_xmit().
> 
> In handle_dev_cpu_collision() use kfree_skb_list() in error handling.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks for catching the kfree_skb_list() issue.
