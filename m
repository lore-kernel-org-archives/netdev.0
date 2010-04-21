From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] KS8851: NULL pointer dereference if list is empty
Date: Wed, 21 Apr 2010 16:29:32 -0700 (PDT)
Message-ID: <20100421.162932.191667410.davem@davemloft.net>
References: <k2ocb8016981004161748s1a91f926x3c29b3fbd45ad46c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: abraham.arce.moreno@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57393
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754835Ab0DUX32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:29:28 -0400
In-Reply-To: <k2ocb8016981004161748s1a91f926x3c29b3fbd45ad46c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Abraham Arce <abraham.arce.moreno@gmail.com>
Date: Fri, 16 Apr 2010 19:48:43 -0500

> Fix NULL pointer dereference in ks8851_tx_work by checking if dequeued
> list is already empty before writing the packet to TX FIFO
> 
>  Unable to handle kernel NULL pointer dereference at virtual address 00000050
>  PC is at ks8851_tx_work+0xdc/0x1b0
>  LR is at wait_for_common+0x148/0x164
>  pc : [<c01c0df4>]    lr : [<c025a980>]    psr: 20000013
>  Backtrace:
>   ks8851_tx_work+0x0/0x1b0
>   worker_thread+0x0/0x190
>   kthread+0x0/0x90
> 
> Signed-off-by: Abraham Arce <x0066660@ti.com>

Applied to net-2.6, thanks.
