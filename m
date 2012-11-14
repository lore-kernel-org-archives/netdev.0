From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Tue, 13 Nov 2012 20:24:08 -0500 (EST)
Message-ID: <20121113.202408.79469396824848499.davem@davemloft.net>
References: <1352845788.6276.28.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<20121113.181600.667479923208656972.davem@davemloft.net>
	<1352850029.6276.52.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152Ab2KNBYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 20:24:11 -0500
In-Reply-To: <1352850029.6276.52.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 13 Nov 2012 15:40:29 -0800

> I suppose we can just put the SAN MAC into the real netdev->dev_addr so
> that the VLAN will automatically get it.  But this doesn't seem very
> nice as we would be pretending to have a normal MAC address (for
> networking) in this SAN device.  The networking MAC address is in a
> different PCI function.

I certainly would prefer if you took that approach.  At least in that
way the addressing of the netdev objects would appear more consistent.

Thanks.
