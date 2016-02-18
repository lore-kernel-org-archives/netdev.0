From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre: clear IFF_TX_SKB_SHARING
Date: Thu, 18 Feb 2016 14:56:09 -0500 (EST)
Message-ID: <20160218.145609.1970279810777361874.davem@davemloft.net>
References: <48849b92d89431da841577f06cfd90a4b4130702.1455719517.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1947516AbcBRT4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 14:56:10 -0500
In-Reply-To: <48849b92d89431da841577f06cfd90a4b4130702.1455719517.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 17 Feb 2016 15:32:53 +0100

> ether_setup sets IFF_TX_SKB_SHARING but this is not supported by gre as it
> modifies the skb on xmit.
> 
> Also, clean up whitespace in ipgre_tap_setup when we're already touching it.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
