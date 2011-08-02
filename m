From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 28/71] 8139*/atp/r8169/sc92031: Move the Realtek
 drivers
Date: Mon, 01 Aug 2011 20:48:40 -0700 (PDT)
Message-ID: <20110801.204840.1467588276691539635.davem@davemloft.net>
References: <1312082850-24914-29-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312244694.2591.42.camel@deadeye>
	<4E376D30.6050406@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	nic_swsd@realtek.com, romieu@fr.zoreil.com, becker@scyld.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab1HBDtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 23:49:13 -0400
In-Reply-To: <4E376D30.6050406@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jgarzik@pobox.com>
Date: Mon, 01 Aug 2011 23:21:20 -0400

> On 08/01/2011 08:24 PM, Ben Hutchings wrote:
>> On Sat, 2011-07-30 at 20:26 -0700, Jeff Kirsher wrote:
>>> Move the Realtek drivers into drivers/net/ethernet/realtek/ and make
>>> the necessary Kconfig and Makefile changes.
>> [...]
>>
>> Does it really make sense to move the pci-skeleton driver?  Although
>> it
>> includes hardware access specific to RTL8139 chips, that's not really
>> the point of it.
> 
> Indeed.  pci-skeleton was simply intended to illustrate a clean driver
> for a simple DMA-driven NIC.
> 
> Honestly, it's so outdated now that deletion would be a better course.

Yeah, this is probably true.
