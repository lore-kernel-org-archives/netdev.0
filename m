From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET 04/05]: dev: secondary unicast address support
Date: Wed, 27 Jun 2007 10:30:09 +0200
Message-ID: <46822011.3030406@trash.net>
References: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>	<20070622122336.15215.95560.sendpatchset@localhost.localdomain> <20070627.012840.98863737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51141 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750AbXF0Iab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 04:30:31 -0400
In-Reply-To: <20070627.012840.98863737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 22 Jun 2007 14:24:12 +0200 (MEST)
> 
> 
>>[NET]: dev: secondary unicast address support
>>
>>Add support for configuring secondary unicast addresses on network
>>devices. To support this devices capable of filtering multiple
>>unicast addresses need to change their set_multicast_list function
>>to configure unicast filters as well and assign it to dev->set_rx_mode
>>instead of dev->set_multicast_list. Other devices are put into promiscous
>>mode when secondary unicast addresses are present.
>>
>>Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> 
> Also applied, thanks for doing this work Patrick.


Thanks. Please hold off on the MACVLAN patch, I want to convert it
to use this stuff before adding it.

