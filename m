From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/udp_offload: Handle static checker
 complaints
Date: Thu, 23 Jan 2014 12:59:28 -0800 (PST)
Message-ID: <20140123.125928.615354504249618511.davem@davemloft.net>
References: <1390397009-28280-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shlomop@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbaAWU73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 15:59:29 -0500
In-Reply-To: <1390397009-28280-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 22 Jan 2014 15:23:29 +0200

> From: Shlomo Pongratz <shlomop@mellanox.com>
> 
> Fixed few issues around using __rcu prefix and rcu_assign_pointer, also
> fixed a warning print to use ntohs(port) and not htons(port).
> 
> net/ipv4/udp_offload.c:112:9: error: incompatible types in comparison expression (different address spaces)
> net/ipv4/udp_offload.c:113:9: error: incompatible types in comparison expression (different address spaces)
> net/ipv4/udp_offload.c:176:19: error: incompatible types in comparison expression (different address spaces)
> 
> Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
