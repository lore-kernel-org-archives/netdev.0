From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/8] vxge: Fix a receive stall due to
 driver being out of synch with chip.
Date: Mon, 29 Mar 2010 16:57:43 -0700 (PDT)
Message-ID: <20100329.165743.137823731.davem@davemloft.net>
References: <Pine.GSO.4.10.11003290405250.4435-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45989
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752504Ab0C2X5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 19:57:42 -0400
In-Reply-To: <Pine.GSO.4.10.11003290405250.4435-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Mon, 29 Mar 2010 04:07:34 -0400 (EDT)

> - Fix a receive stall due to driver being out of synch with chip. In a corner 
> case scenario the adapter's ring controller may return a RxD with transfer code
> of 0xC, while the host ownership bit is still set to the adapter. The driver 
> needs to assume that this case where (host_ownership == 1 or adapter) and 
> (transfer_code == 0xC) is valid, that is, this RxD has been returned by the 
> receive ring controller but no frame data is associated with the rxd.
> 
> - Restore the transfer code field of each newly replenished RxD to 0x0. 
> 
> - Code cleanup. Removed usage of magic numbers.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

Applied.
