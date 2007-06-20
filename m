From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET 00/02]: MACVLAN driver
Date: Wed, 20 Jun 2007 02:34:39 -0400
Message-ID: <4678CA7F.8070002@garzik.org>
References: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>	<20070619090027.3312f2cf@localhost.localdomain>	<4678472D.5050907@trash.net> <20070619.154840.55744015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38733 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758028AbXFTGep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 02:34:45 -0400
In-Reply-To: <20070619.154840.55744015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> This is actually a real issue for virtualization, and many
> if not all current generation ethernet chips support
> programming several unicast ethernet addresses in the MAC.
> 
> Networking switches in domain0 on virtualization hosts use
> this feature to support seperate MACs per guest node,
> and if the chip doesn't support this the chip is put into
> promiscuous mode.
> 
> We don't have any clean interfaces by which to do this MAC
> programming, and we do need something for it soon.


Yep, that's been on my long term wish list for a while, as well.

Overall I would like to see a more flexible way of allowing the net 
stack to learn each NIC's RX filter capabilities, and exploiting them. 
Plenty of NICs, even 100Mbps ones, support RX filter management that 
allows scanning for $hw_limit unicast addresses, before having to put 
the hardware into promisc mode.

	Jeff


