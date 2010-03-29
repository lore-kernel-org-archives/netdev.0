From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/8] vxge: Fix starvation of receive ring
 controller when blasted by short packets.
Date: Mon, 29 Mar 2010 16:57:50 -0700 (PDT)
Message-ID: <20100329.165750.258976081.davem@davemloft.net>
References: <Pine.GSO.4.10.11003290407500.4435-100000@guinness>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa.Honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45994
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753069Ab0C2X5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 19:57:49 -0400
In-Reply-To: <Pine.GSO.4.10.11003290407500.4435-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Date: Mon, 29 Mar 2010 04:08:30 -0400 (EDT)

> - Fix starvation of receive ring controller when blasted by short packets. This was because the driver was posting 64 rxds initially while the ring controller 
> was expecting to read 256 replenished rxds. While the driver was coming up, 
> the internal rxd memory filled up the 64 buffers provided and the ring 
> controller was left waiting for the remaining 192 rxds to complete the write
> back of completed rxds to the host and generation of an interrupt.
> 
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>

Applied.
