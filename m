From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Mon, 16 Jul 2007 15:13:22 +0200
Message-ID: <469B6EF2.50405@trash.net>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org> <469631F5.7080207@trash.net> <46963457.1000306@openvz.org> <46963673.3010506@trash.net> <469B3789.8030303@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49996 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756125AbXGPNOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 09:14:54 -0400
In-Reply-To: <469B3789.8030303@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Patrick McHardy wrote:
> 
>> You don't have a struct ifinfomsg for the peer device. At some
>> point we might want to add support for specifying initial flags
>> for the device (some easily supportable ones are IFF_PROMISC,
>> IFF_ALLMULTI, IFF_NOARP) and ideally that should also be possible
>> for the peer device.
>>
>> So I suggest you use a complete ifinfomsg including the header
>> instead of just the attributes for VETH_INFO_PEER.
>>
>>
> 
> I don't see any information from this struct being used on the
> link-creation paths...


Thats what I explained twice, its not used today, it might be
used in the future for ifindex and flags.

