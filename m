From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: propagate state of link back go to tunnel
Date: Wed, 21 Mar 2012 22:18:39 -0400 (EDT)
Message-ID: <20120321.221839.274547591318904841.davem@davemloft.net>
References: <20120319165843.7b18412a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753725Ab2CVCSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 22:18:44 -0400
In-Reply-To: <20120319165843.7b18412a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 19 Mar 2012 16:58:43 -0700

> GRE tunnels like other layered devices should propagate
> carrier and RFC2863 state from lower device to tunnel.
> Based on similar code in vlan device driver.
> By using operstate it is possible for user mode to create tunnel
> and use stepped outlined in Documentation/networking/operstate.txt
> to control carrier.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Not urgent, can wait if the release window is already over the
> queue limit

Yeah, please resubmit this once net-next opens back up.

And meanwhile you can duplicate this fix to ipip, sit, ip6_tunnel etc.
