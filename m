From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: allow creating vlan when real device is not up
Date: Fri, 31 Jul 2009 14:16:11 +0200
Message-ID: <4A72E08B.4070709@trash.net>
References: <20090730112321.35753739@nehalam> <20090730.131710.208062164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34292 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbZGaMQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 08:16:15 -0400
In-Reply-To: <20090730.131710.208062164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 30 Jul 2009 11:23:21 -0700
> 
>> There is no reason for the arbitrary restriction that device must be
>> up to create a vlan. This patch was added to Vyatta kernel to resolve startup
>> ordering issues where vlan's are created but real device was disabled.
>>
>> Note: the vlan already correctly inherits the operstate from real device; so
>> if vlan is created and real device is marked down, the vlan is marked
>> down.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Looks fine, added to net-next-2.6
> 
> We can revert if Patrick or someone else finds a potential problem
> with allowing this.

It seems perfectly fine to me, we can get to the same state by
setting the lower device down after creating the VLAN device.
