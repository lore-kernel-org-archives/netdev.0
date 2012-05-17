From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: num cores tx rings for every UP
Date: Thu, 17 May 2012 16:19:03 -0400 (EDT)
Message-ID: <20120517.161903.1659292198324734622.davem@davemloft.net>
References: <1337252290-20444-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oren@mellanox.com,
	john.r.fastabend@intel.com, liranl@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34728 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757656Ab2EQUTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 16:19:14 -0400
In-Reply-To: <1337252290-20444-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 17 May 2012 13:58:10 +0300

> Change the TX ring scheme such that the number of rings for untagged packets
> and for tagged packets (per each of the vlan priorities) is the same, unlike
> the current situation where for tagged traffic there's one ring per priority
> and for untagged rings as the number of core.
> 
> Queue selection is done as follows:
> 
> If the mqprio qdisc is operates on the interface, such that the core networking
> code invoked the device setup_tc ndo callback, a mapping of skb->priority =>
> queue set is forced - for both, tagged and untagged traffic.
> 
> Else, the egress map skb->priority =>  User priority is used for tagged traffic, and
> all untagged traffic is sent through tx rings of UP 0.
> 
> The patch follows the convergence of discussing that issue with John Fastabend
> over this thread http://comments.gmane.org/gmane.linux.network/229877
> 
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Liran Liss <liranl@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
