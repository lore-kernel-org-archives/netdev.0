From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet/ixp4xx: prevent allmulti from clobbering
 promisc
Date: Fri, 20 Feb 2015 15:49:27 -0500 (EST)
Message-ID: <20150220.154927.313372314025203773.davem@davemloft.net>
References: <1424249425-2438-1-git-send-email-pallas@meraki.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khalasa@piap.pl, netdev@vger.kernel.org
To: pallas@meraki.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753001AbbBTUt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 15:49:29 -0500
In-Reply-To: <1424249425-2438-1-git-send-email-pallas@meraki.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Derrick Pallas <pallas@meraki.com>
Date: Wed, 18 Feb 2015 00:50:25 -0800

> If both promisc and allmulti are set, promisc should trump allmulti and
> disable the MAC filter; otherwise, the interface is not really promisc.
> 
> Previously, this code checked IFF_ALLMULTI prior to and without regard for
> IFF_PROMISC; if both were set, only multicast and direct unicast traffic
> would make it through the filter.
> 
> Signed-off-by: Derrick Pallas <pallas@meraki.com>

Applied, thanks.
