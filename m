From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] net: Reset encap_level to avoid resetting features
 on inner IP headers
Date: Wed, 23 Mar 2016 14:19:44 -0400 (EDT)
Message-ID: <20160323.141944.223192963031809374.davem@davemloft.net>
References: <20160322231732.13054.71337.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, kernel-team@fb.com, alexander.duyck@gmail.com,
	netdev@vger.kernel.org
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756015AbcCWSTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 14:19:49 -0400
In-Reply-To: <20160322231732.13054.71337.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Tue, 22 Mar 2016 16:18:07 -0700

> This patch corrects an oversight in which we were allowing the encap_level
> value to pass from the outer headers to the inner headers.  As a result we
> were incorrectly identifying UDP or GRE tunnels as also making use of ipip
> or sit when the second header actually represented a tunnel encapsulated in
> either a UDP or GRE tunnel which already had the features masked.
> 
> Fixes: 76443456227097179c1482 ("net: Move GSO csum into SKB_GSO_CB")
> Reported-by: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied, thanks.
