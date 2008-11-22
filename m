From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 07/14] e1000e: ESB2 config after link up
Date: Fri, 21 Nov 2008 16:53:58 -0800 (PST)
Message-ID: <20081121.165358.262920660.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121190052.32313.88452.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42271
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757847AbYKVAx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:53:59 -0500
In-Reply-To: <20081121190052.32313.88452.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 11:00:52 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> On ESB2, the MAC-to-PHY (Kumeran) interface must be configured after link
> is up before any traffic is sent; a new PHY operations function pointer is
> provided for this.  To facilitate read/write of the Kumeran registers
> without blocking PHY register writes, the driver/firmware synchronization
> method which previously used a hardware semaphore for both PHY and Kumeran
> register accesses is now split.  New Kumeran register read/write functions
> utilize this new synchronization method.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
