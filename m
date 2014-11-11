From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Advertize encapsulation offloads
 features only when VXLAN tunnel is set
Date: Tue, 11 Nov 2014 13:25:07 -0500 (EST)
Message-ID: <20141111.132507.1592542926431906997.davem@davemloft.net>
References: <1415535939-30681-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, amirv@mellanox.com,
	saeedm@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbaKKSZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 13:25:10 -0500
In-Reply-To: <1415535939-30681-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  9 Nov 2014 14:25:39 +0200

> Currenly we only support Large-Send and TX checksum offloads for
> encapsulated traffic of type VXLAN. We must make sure to advertize
> these offloads up to the stack only when VXLAN tunnel is set.
> 
> Failing to do so, would mislead the the networking stack to assume
> that the driver can offload the internal TX checksum for GRE packets
> and other buggy schemes.
> 
> Reported-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
