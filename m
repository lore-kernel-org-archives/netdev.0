From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2 net-next 1/7] epic100: replace printk with netdev_
 calls
Date: Thu, 31 Oct 2013 21:36:12 -0700
Message-ID: <1383280572.13084.2.camel@joe-AO722>
References: <1382682422-22677-1-git-send-email-mathstuf@gmail.com>
	 <1383280043-13552-1-git-send-email-mathstuf@gmail.com>
	 <1383280043-13552-2-git-send-email-mathstuf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Boeckel <mathstuf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0130.hostedemail.com ([216.40.44.130]:40568 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750738Ab3KAEgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 00:36:14 -0400
In-Reply-To: <1383280043-13552-2-git-send-email-mathstuf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-01 at 00:27 -0400, Ben Boeckel wrote:
> Signed-off-by: Ben Boeckel <mathstuf@gmail.com>

Nice (really, nicely done!) but:

> diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
[]
> @@ -1324,7 +1316,7 @@ static int epic_close(struct net_device *dev)
>  		ep->rx_ring[i].buflength = 0;
>  		if (skb) {
>  			pci_unmap_single(pdev, ep->rx_ring[i].bufaddr,
> -				 	 ep->rx_buf_sz, PCI_DMA_FROMDEVICE);
> +					 ep->rx_buf_sz, PCI_DMA_FROMDEVICE);

Please either mention the whitespace changes in the
changelog or don't do them in the same patch.
