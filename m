From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipv6: router reachability probing
Date: Wed, 11 Dec 2013 19:56:51 -0500 (EST)
Message-ID: <20131211.195651.959794720995269703.davem@davemloft.net>
References: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com>
	<20131211231236.GA8953@lion.mk-sys.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org, yoshfuji@linux-ipv6.org
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000Ab3LLA4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 19:56:53 -0500
In-Reply-To: <20131211231236.GA8953@lion.mk-sys.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Thu, 12 Dec 2013 00:12:36 +0100

> Is it really the case in current mainline kernels? In my tests, this
> behaviour in 3.0 kernel (SLES 11 SP3) was caused by the reference held
> by struct dst_entry which caused that in neigh_periodic_work(),
> n->refcnt was always bigger than one so that the neighbour entry was
> never cleaned up.  But when I tested with 3.11.6 (OpenSuSE 13.1) where
> neighbour is no longer cached in struct dst_entry, the neighbour was
> cleaned up eventually and new lookup was performed.

The detachment of neighbours from route entires has had many consequences,
both desirable and undesirable.  This happens to be one of the former,
fortunately :-)
