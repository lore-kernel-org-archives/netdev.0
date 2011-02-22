From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TX timestamp IPv6 support
Date: Tue, 22 Feb 2011 09:36:33 -0800 (PST)
Message-ID: <20110222.093633.193722951.davem@davemloft.net>
References: <41D1D4BB-0CED-4396-B0FA-1DC42296DBCF@halon.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com
To: anders@halon.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43884
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751131Ab1BVRf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 12:35:56 -0500
In-Reply-To: <41D1D4BB-0CED-4396-B0FA-1DC42296DBCF@halon.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anders Berggren <anders@halon.se>
Date: Tue, 15 Feb 2011 14:56:21 +0100

> This patch enables UDP IPv6 TX timestamping (using SO_TIMESTAMPING,
> enabled by CONFIG_NETWORK_PHY_TIMESTAMPING) as Marcus D. Leech
> suggested in
> http://kerneltrap.org/mailarchive/linux-netdev/2009/11/10/6260604
> and
> http://kerneltrap.org/mailarchive/linux-netdev/2009/11/11/6260643
> 
> It's mostly copied from net/ipv4/udp.c. I guess it would be better
> to run sock_tx_timestamp in ipv6/udp.c and pass it to
> ipv6/ip6_output.c's ip6_append_data somehow, but I didn't find a
> suitable struct to extend for this purpose.

Please submit your change properly, as per Documentation/SubmittingPatches,
in particular you need to provide a proper Signed-off-by: tag for your
change.

