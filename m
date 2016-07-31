From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4/cxgb4vf: Fixes regression in perf when tx
 vlan offload is disabled
Date: Sat, 30 Jul 2016 20:40:11 -0700 (PDT)
Message-ID: <20160730.204011.1392704517724269934.davem@davemloft.net>
References: <1469692737-19583-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492AbcGaDkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 23:40:12 -0400
In-Reply-To: <1469692737-19583-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Thu, 28 Jul 2016 13:28:57 +0530

> The commit 637d3e997351 ("cxgb4: Discard the packet if the length is
> greater than mtu") introduced a regression in the VLAN interface
> performance when Tx VLAN offload is disabled.
> 
> Check if skb is tagged, regardless of whether it is hardware accelerated
> or not. Presently we were checking only for hardware acclereated one,
> which caused performance to drop to ~0.17Mbps on a 10GbE adapter for
> VLAN interface, when tx vlan offload is turned off using ethtool.
> The ethernet head length calculation was going wrong in this case, and
> driver ended up dropping packets.
> 
> Fixes: 637d3e997351 ("cxgb4: Discard the packet if the length is greater than mtu")
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
