From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] GSO: Provide software checksum of tunneled
 UDP fragmentation offload
Date: Fri, 26 Feb 2016 14:24:52 -0500 (EST)
Message-ID: <20160226.142452.543171201728476637.davem@davemloft.net>
References: <20160225004621.22152.21938.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422808AbcBZTYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 14:24:54 -0500
In-Reply-To: <20160225004621.22152.21938.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Wed, 24 Feb 2016 16:46:21 -0800

> On reviewing the code I realized that GRE and UDP tunnels could cause a
> kernel panic if we used GSO to segment a large UDP frame that was sent
> through the tunnel with an outer checksum and hardware offloads were not
> available.
> 
> In order to correct this we need to update the feature flags that are
> passed to the skb_segment function so that in the event of UDP
> fragmentation being requested for the inner header the segmentation
> function will correctly generate the checksum for the payload if we cannot
> segment the outer header.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied, thanks Alex.
