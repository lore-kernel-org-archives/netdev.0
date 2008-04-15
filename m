From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26 3/10][VLAN]: Tag vlan_group_device with net
 device, not ifindex.
Date: Tue, 15 Apr 2008 14:03:08 +0200
Message-ID: <4804997C.6090107@trash.net>
References: <4804989F.1060503@openvz.org> <480499F9.4050808@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35282 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762263AbYDOMDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 08:03:13 -0400
In-Reply-To: <480499F9.4050808@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Currently vlan group is searched using one key - the ifindex.
> We'll have to lookup the vlan_group by two keys - ifindex and
> net. Turning the vlan_group lookup key to struct net_device
> pointer will make this process easier.
> 
> Besides, this will eliminate one more place in the networking,
> that assumes that indexes are unique in the kernel.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Patrick McHardy <kaber@trash.net>
