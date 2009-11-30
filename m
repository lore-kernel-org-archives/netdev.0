From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/12] sfc: Extend MTD driver for use with new NICs
Date: Sun, 29 Nov 2009 17:24:30 -0800 (PST)
Message-ID: <20091129.172430.95886199.davem@davemloft.net>
References: <1259543444.3709.88.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46043
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752284AbZK3BYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 20:24:24 -0500
In-Reply-To: <1259543444.3709.88.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 30 Nov 2009 01:10:44 +0000

> In new NICs flash is managed by firmware and we will use high-level
> operations on partitions rather than direct SPI commands.  Add support
> for multiple MTD partitions per flash device and remove the direct
> link between MTD and SPI devices.  Maintain a list of MTD partitions
> in struct efx_nic.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
