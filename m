From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v5] vlan: Propagate MAC address to VLANs
Date: Tue, 31 May 2016 11:57:13 -0700 (PDT)
Message-ID: <20160531.115713.311863106863253136.davem@davemloft.net>
References: <57487691.7090808@brocade.com>
	<57487993.2040609@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756290AbcEaS5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:57:14 -0400
In-Reply-To: <57487993.2040609@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Fri, 27 May 2016 17:45:07 +0100

> The MAC address of the physical interface is only copied to the VLAN
> when it is first created, resulting in an inconsistency after MAC
> address changes of only newly created VLANs having an up-to-date MAC.
> 
> The VLANs should continue inheriting the MAC address of the physical
> interface until the VLAN MAC address is explicitly set to any value. 
> This allows IPv6 EUI64 addresses for the VLAN to reflect any changes
> to the MAC of the physical interface and thus for DAD to behave as
> expected.
> 
> Signed-off-by: Mike Manning <mmanning@brocade.com>

Applied, thanks Mike.
