From: David Miller <davem@davemloft.net>
Subject: Re: can: make the number of echo skb's configurable
Date: Tue, 13 Oct 2009 03:46:53 -0700 (PDT)
Message-ID: <20091013.034653.131762057.davem@davemloft.net>
References: <4ACEEFA6.1000904@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	anantgole@ti.com, haas@ems-wuensche.com
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756051AbZJMKq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 06:46:57 -0400
In-Reply-To: <4ACEEFA6.1000904@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Fri, 09 Oct 2009 10:09:10 +0200

> This patch allows the CAN controller driver to define the number of echo
> skb's used for the local loopback (echo), as suggested by Kurt Van
> Dijck, with the function:
> 
>   struct net_device *alloc_candev(int sizeof_priv,
>                                   unsigned int echo_skb_max);
> 
> The CAN drivers have been adapted accordingly. For the ems_usb driver,
> as suggested by Sebastian Haas, the number of echo skb's has been
> increased to 10, which improves the transmission performance a lot.
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>

Applied, thanks.
