From: Kyle McMartin <kmcmarti@redhat.com>
Subject: Re: [PATCH] xgmac: use bufsz not dma_buf_sz in rx_refill
Date: Thu, 29 Aug 2013 16:35:23 -0400
Message-ID: <20130829203523.GL8764@redacted.bos.redhat.com>
References: <20130829201151.GJ8764@redacted.bos.redhat.com>
 <20130829.163437.1817937756134021051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rob.herring@calxeda.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756080Ab3H2Uf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 16:35:27 -0400
Content-Disposition: inline
In-Reply-To: <20130829.163437.1817937756134021051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 29, 2013 at 04:34:37PM -0400, David Miller wrote:
> From: Kyle McMartin <kyle@redhat.com>
> Date: Thu, 29 Aug 2013 16:11:51 -0400
> 
> > Noticed while debugging another issue that DMA debug turned up, looks
> > like commit ef468d23 missed a case when switching to bufsz instead of
> > priv->dma_buf_sz? (tbf, the whole handling of DMA buffers seems slightly
> > suspect since we're not tracking the size, but trusting the hardware
> > between map and unmap...)
> > 
> > Signed-off-by: Kyle McMartin <kyle@redhat.com>
> 
> Applied and queued up for -stable, thanks.

Heh, too fast David, Rob nak'd it. :)

Sorry about that.

--Kyle
