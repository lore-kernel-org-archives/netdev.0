From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH] ixgbe: fix compilation with gcc-3.4
Date: Thu, 20 Nov 2008 00:45:31 -0800 (PST)
Message-ID: <20081120.004531.161894913.davem@davemloft.net>
References: <20081118010417.7521.37340.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35881
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753841AbYKTIpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:45:31 -0500
In-Reply-To: <20081118010417.7521.37340.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 17 Nov 2008 17:04:17 -0800

> From: Alexey Dobriyan <adobriyan@gmail.com>
> 
> CC [M]  drivers/net/ixgbe/ixgbe_main.o
> drivers/net/ixgbe/ixgbe_main.c: In function `ixgbe_intr':
> drivers/net/ixgbe/ixgbe_main.c:1290: sorry, unimplemented: inlining failed in call to 'ixgbe_irq_enable': function body not available
> drivers/net/ixgbe/ixgbe_main.c:1312: sorry, unimplemented: called from here
> make[4]: *** [drivers/net/ixgbe/ixgbe_main.o] Error 1
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Already in my net-2.6 tree.
