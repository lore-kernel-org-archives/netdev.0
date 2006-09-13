From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: mv643xx_eth: Unmap DMA buffers in receive path
Date: Tue, 12 Sep 2006 22:05:40 -0400
Message-ID: <45076774.5030909@pobox.com>
References: <20060912182229.GA11522@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Manish Lachwani <mlachwani@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:61317 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751496AbWIMCFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 22:05:43 -0400
To: Dale Farnsworth <dale@farnsworth.org>
In-Reply-To: <20060912182229.GA11522@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> From: Dale Farnsworth <dale@farnsworth.org>
> 
> Fix a missing call to dma_unmap_single() in the receive path.  Without
> this call, errors have been observed on non-cache-coherent systems.
> 
> Signed-off-by Dale Farnsworth <dale@farnsworth.org>
> 
> ---
> 
>  drivers/net/mv643xx_eth.c |    2 ++
>  1 file changed, 2 insertions(+)

ACK, but


[jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
1 patch(es) to process.

Applying 'mv643xx_eth: Unmap DMA buffers in receive path'

error: patch failed: drivers/net/mv643xx_eth.c:402
error: drivers/net/mv643xx_eth.c: patch does not apply

