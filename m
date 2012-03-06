From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Support sending custom Ethernet CRC.
Date: Mon, 05 Mar 2012 23:12:13 -0500 (EST)
Message-ID: <20120305.231213.1657967586545663587.davem@davemloft.net>
References: <1330999558-14270-1-git-send-email-greearb@candelatech.com>
	<20120305.211449.2159840360912052625.davem@davemloft.net>
	<4F558BBD.1050400@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59329 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964934Ab2CFENS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 23:13:18 -0500
In-Reply-To: <4F558BBD.1050400@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Mon, 05 Mar 2012 19:59:57 -0800

> On 03/05/2012 06:14 PM, David Miller wrote:
>> From: greearb@candelatech.com
>> Date: Mon,  5 Mar 2012 18:05:58 -0800
>>
>>> NOTE:  You will probably have to disable any
>>> VLAN hardware assist on the underlying device to get
>>> this to properly send packets with this feature enabled.
>>
>> This need to be therefore handled specifically on a device-by-device
>> basis, and VLAN custom CRC disabled unless the device explicitly
>> states that it can handle this situation properly and has any
>> necessary feature rule enforcement codified.
> 
> I'll see what I can come up with.  Maybe figure out how to propagate
> a flag up from the NIC when it is in a state that can handle VLAN +
> custom-CRC
> and only enable the flag on the VLAN in that case...

NETIF_F_CAN_VLAN_WITH_CUSTOM_CRC
