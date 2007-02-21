From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] split NAPI from network device.
Date: Tue, 20 Feb 2007 23:47:13 -0800 (PST)
Message-ID: <20070220.234713.59469649.davem@davemloft.net>
References: <20061213154635.1f284bf6@dxpl.pdx.osdl.net>
	<20070220.213125.74747066.davem@davemloft.net>
	<45DBF74B.7070801@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, benh@kernel.crashing.org,
	netdev@vger.kernel.org, ebs@ebshome.net,
	linux-kernel@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43440
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161116AbXBUHrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 02:47:15 -0500
In-Reply-To: <45DBF74B.7070801@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>
Date: Tue, 20 Feb 2007 23:39:55 -0800

> I applied the patch to test the chelsio drivers.
> The compilation of the forcedeth driver fails if CONFIG_FORCEDETH_NAPI 
> is not set.
> /opt/sources/linux-2.6/drivers/net/forcedeth.c: In function `nv_nic_irq':
> /opt/sources/linux-2.6/drivers/net/forcedeth.c:2866: error: structure 
> has no member named `weight'
> /opt/sources/linux-2.6/drivers/net/forcedeth.c: In function 
> `nv_nic_irq_optimized':
> /opt/sources/linux-2.6/drivers/net/forcedeth.c:2983: error: structure 
> has no member named `weight'
> /opt/sources/linux-2.6/drivers/net/forcedeth.c: In function `nv_nic_irq_rx':
> /opt/sources/linux-2.6/drivers/net/forcedeth.c:3177: error: structure 
> has no member named `weight'

Thanks for catching that, I'll fix this up.
