From: David Miller <davem@davemloft.net>
Subject: Re: [patch] mdio_bus: NULL dereference on allocation error
Date: Tue, 12 Jan 2016 14:31:12 -0500 (EST)
Message-ID: <20160112.143112.1804837472013389455.davem@davemloft.net>
References: <20160112093435.GD29804@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53260 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbcALTbN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 14:31:13 -0500
In-Reply-To: <20160112093435.GD29804@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 12 Jan 2016 12:34:36 +0300

> If bus = kzalloc() fails then we end up dereferencing bus when we do
> "bus->irq[i] = PHY_POLL;".  The code is a little simpler if we reverse
> the NULL check and return directly on failure.
> 
> Fixes: e7f4dc3536a4 ('mdio: Move allocation of interrupts into core')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
