From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] qdisc: exit case fixes for skb list handling
 in qdisc layer
Date: Wed, 03 Sep 2014 20:42:56 -0700 (PDT)
Message-ID: <20140903.204256.1398300065789241714.davem@davemloft.net>
References: <1409671557.3173.110.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140903101250.7668.91659.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, hannes@stressinduktion.org,
	dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932163AbaIDDlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 23:41:55 -0400
In-Reply-To: <20140903101250.7668.91659.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 03 Sep 2014 12:12:50 +0200

> More minor fixes to merge commit 53fda7f7f9e (Merge branch 'xmit_list')
> that allows us to work with a list of SKBs.
> 
> Fixing exit cases in qdisc_reset() and qdisc_destroy(), where a
> leftover requeued SKB (qdisc->gso_skb) can have the potential of
> being a skb list, thus use kfree_skb_list().
> 
> This is a followup to commit 10770bc2d1 ("qdisc: adjustments for
> API allowing skb list xmits").
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied.
