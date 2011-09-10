From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac_esp: remove redundant mutual exclusion
Date: Sat, 10 Sep 2011 14:28:50 -0400 (EDT)
Message-ID: <20110910.142850.1601261425101118430.davem@davemloft.net>
References: <alpine.LNX.2.00.1109110038500.5327@nippy.intranet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1109110038500.5327@nippy.intranet>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Sun, 11 Sep 2011 01:01:34 +1000 (EST)

> Mutual exclusion is redundant here because all the paths in the call graph 
> leading to esp_driver_ops.send_dma_cmd() happen under spin_lock_irqsave/ 
> spin_lock_irqrestore. Remove it.
> 
> Tested on a Mac Quadra 660av and a Mac LC 630.
> 
> Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

This patch should be CC:'d to linux-scsi not netdev

I understand how the networking maintainer is very responsive
and the SCSI maintainer generally takes forever, so your
Freudian slip will go unjudged :-)
