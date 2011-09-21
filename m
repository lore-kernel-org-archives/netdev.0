From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macmace, macsonic: cleanup
Date: Wed, 21 Sep 2011 15:31:46 -0400 (EDT)
Message-ID: <20110921.153146.2033377674238625359.davem@davemloft.net>
References: <alpine.LNX.2.00.1109140317300.20729@nippy.intranet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1109140317300.20729@nippy.intranet>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Wed, 14 Sep 2011 03:30:25 +1000 (EST)

> 
> We check ether_type before registering the platform device in 
> arch/m68k/mac/config.c. Doing the same test again in the driver is 
> redundant so remove it.
> 
> Multiple probes should not happen since the conversion to platform devices,
> so lose that test too.
> 
> Then macmace.c need not include macintosh.h, so remove that and irq.h and 
> include linux/interrupt.h explicitly.
> 
> Tested on PowerBook 520, Quadra 660av, LC 630.
> 
> Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Applied to net-next, thanks.
