From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: Remote checksum offload for VXLAN
Date: Tue, 25 Nov 2014 13:50:38 -0500 (EST)
Message-ID: <20141125.135038.450259284061493243.davem@davemloft.net>
References: <1416873150-12260-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36861 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbaKYSuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 13:50:40 -0500
In-Reply-To: <1416873150-12260-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 24 Nov 2014 15:52:27 -0800

> This patch set adds support for remote checksum offload in VXLAN.
> 
> The remote checksum offload is generalized by creating a common
> function (remcsum_adjust) that does the work of modifying the
> checksum in remote checksum offload. This function can be called
> from normal or GRO path. GUE was modified to use this function.
> 
> To support RCO is VXLAN we use the 9th bit in the reserved
> flags to indicated remote checksum offload. The start and offset
> values are encoded n a compressed form in the low order (reserved)
> byte of the vni field.
> 
> Remote checksum offload is described in
> https://tools.ietf.org/html/draft-herbert-remotecsumoffload-01
> 
> Tested by running 200 TCP_STREAM connections with VXLAN (over IPv4).

What to do with the reserved bit seems to still be up in the air,
so I've marked this series as 'deferred'.
