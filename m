From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 001/001] vlan: don't call ndo_vlan_rx_register on
 hardware that doesn't have vlan support
Date: Fri, 17 Jun 2011 15:11:53 -0400 (EDT)
Message-ID: <20110617.151153.65315210241455903.davem@davemloft.net>
References: <BANLkTimBm8rFF41RzAN6vk3o6SLy6cfZDQ@mail.gmail.com>
	<20110617.001310.887138223551857478.davem@davemloft.net>
	<20110617120032.6ed3ae3c@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.reversat@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932702Ab1FQTL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:11:57 -0400
In-Reply-To: <20110617120032.6ed3ae3c@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 17 Jun 2011 12:00:32 -0700

> On Fri, 17 Jun 2011 00:13:10 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: Antoine Reversat <a.reversat@gmail.com>
>> Date: Thu, 16 Jun 2011 16:47:13 -0400
>> 
>> > This patch removes the call to ndo_vlan_rx_register if the underlying
>> > device doesn't have hardware support for VLAN.
>> > Signed-off-by: Antoine Reversat <a.reversat@gmail.com>
>> 
>> Applied, thanks.
> 
> Need same check for unregister?

What unregister?  There is only ->ndo_vlan_rx_register(), no such
->ndo_vlan_rx_unregister() op exists.
