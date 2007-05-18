From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] small netdevices.txt fix
Date: Thu, 17 May 2007 20:44:26 -0400
Message-ID: <464CF6EA.7090602@garzik.org>
References: <20070516125904.GA1322@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43522 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755323AbXERAoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:44:32 -0400
In-Reply-To: <20070516125904.GA1322@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Index: linux-2.6/Documentation/networking/netdevices.txt
> ===================================================================
> --- linux-2.6.orig/Documentation/networking/netdevices.txt	2007-01-04 19:38:05.000000000 +0100
> +++ linux-2.6/Documentation/networking/netdevices.txt	2007-01-04 19:40:22.000000000 +0100
> @@ -49,7 +49,7 @@
>  	for this and return -1 when the spin lock fails. 
>  	The locking there should also properly protect against 
>  	set_multicast_list
> -	Context: BHs disabled
> +	Context: Process with BHs disabled or BH (timer).
>  	Notes: netif_queue_stopped() is guaranteed false
>                 Interrupts must be enabled when calling hard_start_xmit.
>                  (Interrupts must also be enabled when enabling the BH handler.)

applied


