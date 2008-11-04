From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding, net: Move last_rx update into
 bonding recv logic
Date: Mon, 03 Nov 2008 18:17:03 -0800 (PST)
Message-ID: <20081103.181703.04882118.davem@davemloft.net>
References: <22495.1225498593@death.nxdomain.ibm.com>
	<20081101.214008.201420949.davem@davemloft.net>
	<20247.1225764789@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, zbr@ioremap.net,
	ilpo.jarvinen@helsinki.fi, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	efault@gmx.de, akpm@linux-foundation.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48200
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751348AbYKDCR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 21:17:28 -0500
In-Reply-To: <20247.1225764789@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 03 Nov 2008 18:13:09 -0800

> 
> 	The only user of the net_device->last_rx field is bonding.  This
> patch adds a conditional update of last_rx to the bonding special logic
> in skb_bond_should_drop, causing last_rx to only be updated when the ARP
> monitor is running.
> 
> 	This frees network device drivers from the necessity of updating
> last_rx, which can have cache line thrash issues.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks a lot Jay.
