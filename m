From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next] net/vxlan: Share RX skb de-marking and
 checksum checks with ovs
Date: Thu, 23 Jan 2014 13:30:37 -0800 (PST)
Message-ID: <20140123.133037.140802798467455264.davem@davemloft.net>
References: <1390469293-2234-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joseph.gasparakis@intel.com,
	pshelar@nicira.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60440 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbaAWVah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:30:37 -0500
In-Reply-To: <1390469293-2234-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 23 Jan 2014 11:28:13 +0200

> Make sure the practice set by commit 0afb166 "vxlan: Add capability
> of Rx checksum offload for inner packet" is applied when the skb
> goes through the portion of the RX code which is shared between
> vxlan netdevices and ovs vxlan port instances.
> 
> Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied and queued up for -stable, thanks.
