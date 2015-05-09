From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: add support of ethtool get_regs
Date: Sat, 09 May 2015 17:31:25 -0400 (EDT)
Message-ID: <20150509.173125.960563138389004338.davem@davemloft.net>
References: <1431204728-16754-1-git-send-email-tremyfr@gmail.com>
	<20150509211746.GY2067@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tremyfr@gmail.com, B38611@freescale.com, Frank.Li@freescale.com,
	LW@KARO-electronics.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbbEIVb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:31:27 -0400
In-Reply-To: <20150509211746.GY2067@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sat, 9 May 2015 22:17:46 +0100

> On Sat, May 09, 2015 at 10:52:08PM +0200, Philippe Reynes wrote:
>> +static void fec_enet_get_regs(struct net_device *ndev,
>> +			      struct ethtool_regs *regs, void *regbuf)
>> +{
>> +	struct fec_enet_private *fep = netdev_priv(ndev);
>> +
>> +	memcpy_fromio(regbuf, fep->hwp, regs->len);
> 
> Using memcpy_fromio() to copy device registers is not a good idea -
> it can use a variable access size which can cause bus faults.

Agreed.
