From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ipv4: ip_forward: perform skb->pkt_type
 check at the beginning
Date: Thu, 13 Feb 2014 18:36:26 -0500 (EST)
Message-ID: <20140213.183626.638882408860157037.davem@davemloft.net>
References: <1392267536-2453-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694AbaBMXg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:36:27 -0500
In-Reply-To: <1392267536-2453-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Thu, 13 Feb 2014 08:58:56 +0400

> Packets which have L2 address different from ours should be
> already filtered before entering into ip_forward().
> 
> Perform that check at the beginning to avoid processing such packets.
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>

Looks good, applied, thanks.
