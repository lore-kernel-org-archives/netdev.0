From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stop send queue before resetting gianfar
Date: Wed, 15 Apr 2009 02:35:48 -0700 (PDT)
Message-ID: <20090415.023548.116886749.davem@davemloft.net>
References: <200904150951.23711.super.firetwister@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, rini@arvoo.nl,
	afleming@freescale.com
To: super.firetwister@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34389
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754450AbZDOJf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 05:35:57 -0400
In-Reply-To: <200904150951.23711.super.firetwister@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Brunner <super.firetwister@googlemail.com>
Date: Wed, 15 Apr 2009 09:51:23 +0200

> After a transmit timed out, the reset task will be called, which will free the
> allocated resources(stop_gfar). If gfar_poll will be called before the
> resources get allocated again gfar_clean_tx_ring will call
> dev_kfree_skb_any(NULL).
> This Patch calls netif_stop_queue before calling stop_gfar.
> 
> Signed-off-by: Markus Brunner <super.firetwister@gmail.com>

Applied, thanks.
