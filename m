From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] drivers/net: macvtap and tun depend on INET
Date: Thu, 30 Oct 2014 23:50:55 -0400 (EDT)
Message-ID: <20141030.235055.1295392140066333931.davem@davemloft.net>
References: <1414725031.16849.78.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34673 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933816AbaJaDu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 23:50:56 -0400
In-Reply-To: <1414725031.16849.78.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 31 Oct 2014 03:10:31 +0000

> These drivers now call ipv6_proxy_select_ident(), which is defined
> only if CONFIG_INET is enabled.  However, they have really depended
> on CONFIG_INET for as long as they have allowed sending GSO packets
> from userland.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Fixes: f43798c27684 ("tun: Allow GSO using virtio_net_hdr")
> Fixes: b9fb9ee07e67 ("macvtap: add GSO/csum offload support")
> Fixes: 5188cd44c55d ("drivers/net, ipv6: Select IPv6 fragment idents for virtio UFO packets")

Applied and queued up for -stable, thanks Ben.
