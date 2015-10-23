From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvtap: unbreak receiving of gro skb with frag
 list
Date: Fri, 23 Oct 2015 02:35:24 -0700 (PDT)
Message-ID: <20151023.023524.817747898949803431.davem@davemloft.net>
References: <1445576225-27710-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, vyasevic@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33339 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbbJWJS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:18:58 -0400
In-Reply-To: <1445576225-27710-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 23 Oct 2015 00:57:05 -0400

> We don't have fraglist support in TAP_FEATURES. This will lead
> software segmentation of gro skb with frag list. Fixes by having
> frag list support in TAP_FEATURES.
> 
> With this patch single session of netperf receiving were restored from
> about 5Gb/s to about 12Gb/s on mlx4.
> 
> Fixes a567dd6252 ("macvtap: simplify usage of tap_features")
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks Jason.
