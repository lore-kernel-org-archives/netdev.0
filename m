From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Tue, 13 Nov 2012 20:58:45 -0500 (EST)
Message-ID: <20121113.205845.1523743296362293053.davem@davemloft.net>
References: <1352850029.6276.52.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<20121113.202408.79469396824848499.davem@davemloft.net>
	<1352857850.6276.71.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756154Ab2KNB6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 20:58:47 -0500
In-Reply-To: <1352857850.6276.71.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 13 Nov 2012 17:50:50 -0800

> On Tue, 2012-11-13 at 20:24 -0500, David Miller wrote:
>> From: "Michael Chan" <mchan@broadcom.com>
>> Date: Tue, 13 Nov 2012 15:40:29 -0800
>> 
>> > I suppose we can just put the SAN MAC into the real netdev->dev_addr so
>> > that the VLAN will automatically get it.  But this doesn't seem very
>> > nice as we would be pretending to have a normal MAC address (for
>> > networking) in this SAN device.  The networking MAC address is in a
>> > different PCI function.
>> 
>> I certainly would prefer if you took that approach.  At least in that
>> way the addressing of the netdev objects would appear more consistent.
>> 
> Ok.  To be more complete, I think we need to add a flag or something to
> such a netdev to indicate that it is a SAN device only.  What's your
> opinion on that?

Yes, that would describe the limitation you mentioned.  Maybe
add a new netdev->priv_flags for this.
