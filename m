From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: Add spinlocks around registers access
Date: Mon, 19 Jul 2010 13:37:30 -0700 (PDT)
Message-ID: <20100719.133730.228932258.davem@davemloft.net>
References: <20100719123311.21558.37288.stgit@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com,
	stable@kernel.org
To: catalin.marinas@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47690
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966710Ab0GSUhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 16:37:14 -0400
In-Reply-To: <20100719123311.21558.37288.stgit@e102109-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 19 Jul 2010 13:42:51 +0100

> On SMP systems, the SMSC911x registers may be accessed by multiple CPUs
> and this seems to put the chip in an inconsistent state. The patch adds
> spinlocks to the smsc911x_reg_read, smsc911x_reg_write,
> smsc911x_rx_readfifo and smsc911x_tx_writefifo functions.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>

Applied to net-next-2.6, thanks.
