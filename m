From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 04/11] z85230: spinlock logic
Date: Tue, 06 Feb 2007 19:15:49 -0500
Message-ID: <45C91A35.3070209@garzik.org>
References: <200702060032.l160W75a004627@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	alan@lxorguk.ukuu.org.uk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56621 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030273AbXBGAP4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 19:15:56 -0500
In-Reply-To: <200702060032.l160W75a004627@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> 
> At some point someone added a spin_lock(&dev->lock) to the IRQ handler for
> the Z85230 driver.  This actually correctly fixes a bug but the necessary
> changes to remove the chan->lock calls in the event handlers were not made
> (c->lock is the same lock).
> 
> Simona Dascenzo reported the problem with the driver and this patch should
> fix the problem he found.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/wan/z85230.c |   14 +-------------
>  1 file changed, 1 insertion(+), 13 deletions(-)

applied


