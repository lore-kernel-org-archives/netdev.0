From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] net: network drivers should not depend on
 geneve/vxlan
Date: Thu, 21 Apr 2016 15:36:35 -0400 (EDT)
Message-ID: <20160421.153635.1778845733284417120.davem@davemloft.net>
References: <1461114373.2649930.583890089.0C126826@webmail.messagingengine.com>
	<20160419.211134.2163748309501010595.davem@davemloft.net>
	<1461224591.4101216.585253121.498EBE7C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752379AbcDUTgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 15:36:37 -0400
In-Reply-To: <1461224591.4101216.585253121.498EBE7C@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 21 Apr 2016 09:43:11 +0200

> Hi David,
> 
> On Wed, Apr 20, 2016, at 03:11, David Miller wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Wed, 20 Apr 2016 03:06:13 +0200
>> 
>> > On Wed, Apr 20, 2016, at 02:27, David Miller wrote:
>> >> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> >> Date: Mon, 18 Apr 2016 21:19:41 +0200
>> >> 
>> >> > This patchset removes the dependency of network drivers on vxlan or
>> >> > geneve, so those don't get autoloaded when the nic driver is loaded.
>> >> > 
>> >> > Also audited the code such that vxlan_get_rx_port and geneve_get_rx_port
>> >> > are not called without rtnl lock.
>> >> 
>> >> In net-next, the 'qed' driver has tunneling offload support too.
>> >> Don't you need to update this series to handle that driver as
>> >> well?
>> > 
>> > I audited qede as well:
>> > 
>> > qede calls {vxlan,geneve}_get_rx_port only from ndo_open which isn't
>> > reused anywhere else in the driver, only from ndo_open, which holds
>> > rtnl_lock also. Thus the driver is safe and doesn't need a change.
>> 
>> I'm talking about your final patches which elide the dependencies.
> 
> could you look at this again? If you have further feedback I am happy to
> incooperate those.

Series applied, thanks Hannes.
