From: Kyle McMartin <kmcmarti@redhat.com>
Subject: Re: [PATCH] xgmac: use bufsz not dma_buf_sz in rx_refill
Date: Thu, 29 Aug 2013 16:26:02 -0400
Message-ID: <20130829202602.GK8764@redacted.bos.redhat.com>
References: <20130829201151.GJ8764@redacted.bos.redhat.com>
 <521FADFE.7040908@calxeda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rob Herring <rob.herring@calxeda.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585Ab3H2U0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 16:26:06 -0400
Content-Disposition: inline
In-Reply-To: <521FADFE.7040908@calxeda.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 29, 2013 at 03:24:30PM -0500, Rob Herring wrote:
> On 08/29/2013 03:11 PM, Kyle McMartin wrote:
> > Noticed while debugging another issue that DMA debug turned up, looks
> > like commit ef468d23 missed a case when switching to bufsz instead of
> > priv->dma_buf_sz? (tbf, the whole handling of DMA buffers seems slightly
> > suspect since we're not tracking the size, but trusting the hardware
> > between map and unmap...)
> 
> Please see my patch series of fixes:
> 
> http://www.spinics.net/lists/netdev/msg248076.html
> 

Hah, thanks. Yeah, I wondered wtf was up with get_buf_len, but figured
the hardware must have been doing something subtle. ;-)

I'll apply these to our Fedora tree and pass them along for testing.

Thanks Rob.

--Kyle
