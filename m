From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] be2net: Export tunnel offloads only when a
 VxLAN tunnel is created
Date: Thu, 11 Dec 2014 14:44:31 -0500 (EST)
Message-ID: <20141211.144431.135480686828715510.davem@davemloft.net>
References: <1418286287-19738-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758322AbaLKToe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 14:44:34 -0500
In-Reply-To: <1418286287-19738-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Thu, 11 Dec 2014 03:24:47 -0500

> From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
> 
> The encapsulated offload flags shouldn't be unconditionally exported
> to the stack. The stack expects offloading to work across all tunnel
> types when those flags are set. This would break other tunnels (like
> GRE) since be2net currently supports tunnel offload for VxLAN only.
> 
> Also, with VxLANs Skyhawk-R can offload only 1 UDP dport. If more
> than 1 UDP port is added, we should disable offloads in that case too.
> 
> Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
> 
> v2 changes: fix a bad indentation pointed out by Dave M.

Applied, thanks.
