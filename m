From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] mv643xx_eth: Do not modify struct netdev tx_queue_len
Date: Tue, 02 Oct 2007 12:55:29 -0400
Message-ID: <47027801.8040903@pobox.com>
References: <20071001230218.GA27461@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35814 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752210AbXJBQzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 12:55:31 -0400
In-Reply-To: <20071001230218.GA27461@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> From: Dale Farnsworth <dale@farnsworth.org>
> 
> This driver erroneously zeros dev->tx_queue_len, since
> mp->tx_ring_size has not yet been initialized.  Actually,
> the driver shouldn't modify tx_queue_len at all and should
> leave the value set by alloc_etherdev(), currently 1000.
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> ---
> Jeff, this bug was just reported today, or I would have batched
> it with the one I sent you last week.  It's an obvious bugfix,
> so I'm not going to hold it in my queue.
> 
>  drivers/net/mv643xx_eth.c |    1 -
>  1 file changed, 1 deletion(-)

applied


