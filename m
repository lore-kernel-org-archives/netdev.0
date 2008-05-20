From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, VLAN]: Propagate selected feature bits to VLAN devices
Date: Wed, 21 May 2008 01:58:14 +0200
Message-ID: <48336596.1090109@trash.net>
References: <4832E223.7020206@trash.net>	<20080520180528.GU28241@solarflare.com>	<48331914.7050501@trash.net> <20080520.145501.13214341.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55081 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbYETX6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 19:58:15 -0400
In-Reply-To: <20080520.145501.13214341.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 20 May 2008 20:31:48 +0200
> 
>> commit fd467a0422c9c8ddd05c53c4f91d4af71c8fb9ff
>> Author: Patrick McHardy <kaber@trash.net>
>> Date:   Tue May 20 20:31:40 2008 +0200
>>
>>     [VLAN]: Propagate selected feature bits to VLAN devices
>>     
>>     Propagate feature bits from the NETDEV_FEAT_CHANGE notifier. For now
>>     only TSO is propagated for devices that announce their ability to
>>     support TSO in combination with VLAN accel by setting the NETIF_F_VLAN_TSO
>>     flag.
>>     
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Applied, thanks Patrick!


Oops, actually this one was only meant for discussion at this
time. I guess I should give it some testing tommorrow :)
