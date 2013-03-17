From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] generalize VXLAN forwarding tables
Date: Sun, 17 Mar 2013 12:24:48 -0400 (EDT)
Message-ID: <20130317.122448.910703366661693996.davem@davemloft.net>
References: <201303151436.r2FEZpRV032696@lab1.dls>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756168Ab3CQQYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:24:50 -0400
In-Reply-To: <201303151436.r2FEZpRV032696@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <dlstevens@us.ibm.com>
Date: Fri, 15 Mar 2013 10:35:51 -0400

> 
> This patch generalizes VXLAN forwarding table entries allowing an administrator
> to:
> 	1) specify multiple destinations for a given MAC
> 	2) specify alternate vni's in the VXLAN header
> 	3) specify alternate destination UDP ports
> 	4) use multicast MAC addresses as fdb lookup keys
> 	5) specify multicast destinations
> 	6) specify the outgoing interface for forwarded packets
> 
> The combination allows configuration of more complex topologies using VXLAN
> encapsulation.
> 
> Changes since v1: rebase to 3.9.0-rc2
> 
> Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

Looks good, applied, thanks David.

Please format your subject line more appropriately next time,
it should always be of the form:

${subsystem}: Description.

And here I've used:

vxlan: generalize forwarding tables

Thanks.
