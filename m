From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix panic in icmp_route_lookup
Date: Fri, 25 Sep 2015 21:44:35 -0700 (PDT)
Message-ID: <20150925.214435.1302073530508628912.davem@davemloft.net>
References: <1443130289-67664-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, temnota.am@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbbIZEof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 00:44:35 -0400
In-Reply-To: <1443130289-67664-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 24 Sep 2015 15:31:29 -0600

> Andrey reported a panic:
 ...
> Prior to the VRF change the oif was not set in the flow struct, so the
> VRF support should really have only added the vrf_master_ifindex lookup.
> 
> Fixes: 613d09b30f8b ("net: Use VRF device index for lookups on TX")
> Cc: Andrey Melnikov <temnota.am@gmail.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks.
