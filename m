From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCHv5 net-next 1/3] sunvnet: upgrade to VIO protocol version
 1.6
Date: Wed, 17 Sep 2014 18:36:06 -0400
Message-ID: <20140917223606.GL26828@oracle.com>
References: <5419F3F4.9030706@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:28463 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756763AbaIQWgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 18:36:11 -0400
Content-Disposition: inline
In-Reply-To: <5419F3F4.9030706@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (09/17/14 16:49), David L Stevens wrote:
> +	/* MTU negotiation:
> +	 *	< v1.3 - ETH_FRAME_LEN exactly
> +	 *	> v1.3 - MIN(pkt.mtu, VNET_MAX_PACKET, port->rmtu) and change
> +	 *			pkt->mtu for ACK
> +	 *	= v1.3 - ETH_FRAME_LEN + VLAN_HLEN exactly
> +	 */

Comment does not match code. Should be VNET_MAXPACKET.

Also, some general questions- 

how does this work for broadcast packets, e.g., if I do 
   "ping -b <broadcast address> -s 60000"

the 65535 MTU is only useful betwen two guests if 
inter-vnet-link is set to on, right? (i.e., can you use it when you 
go from a guest to another IP address on a different physical host)?

--Sowmini
