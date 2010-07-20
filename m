From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sysfs: add entry to indicate network
 interfaces with random MAC address
Date: Tue, 20 Jul 2010 14:20:45 -0700 (PDT)
Message-ID: <20100720.142045.32697196.davem@davemloft.net>
References: <1279636194.2110.45.camel@achroite.uk.solarflarecom.com>
	<20100720.131748.51255156.davem@davemloft.net>
	<20100720141816.16f0a939@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, sassmann@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, leedom@chelsio.com, harald@redhat.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46594
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932692Ab0GTVU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 17:20:29 -0400
In-Reply-To: <20100720141816.16f0a939@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 20 Jul 2010 14:18:16 -0700

> No one mentioned that the first octet of an Ethernet address already
> indicates "software generated" Ethernet address. Per the standard,
> if bit 1 is set it means address is locally assigned.
> 
> static inline bool is_locally_assigned_ether(const u8 *addr)
> {
> 	return (addr[0] & 0x2) != 0;
> }

W00t!

Indeed, can udev just use that?  :-)
