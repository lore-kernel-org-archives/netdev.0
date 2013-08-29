From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xgmac: use bufsz not dma_buf_sz in rx_refill
Date: Thu, 29 Aug 2013 16:38:00 -0400 (EDT)
Message-ID: <20130829.163800.548945536819504279.davem@davemloft.net>
References: <20130829201151.GJ8764@redacted.bos.redhat.com>
	<521FADFE.7040908@calxeda.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kyle@redhat.com, netdev@vger.kernel.org
To: rob.herring@calxeda.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab3H2UiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:38:02 -0400
In-Reply-To: <521FADFE.7040908@calxeda.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>
Date: Thu, 29 Aug 2013 15:24:30 -0500

> On 08/29/2013 03:11 PM, Kyle McMartin wrote:
>> Noticed while debugging another issue that DMA debug turned up, looks
>> like commit ef468d23 missed a case when switching to bufsz instead of
>> priv->dma_buf_sz? (tbf, the whole handling of DMA buffers seems slightly
>> suspect since we're not tracking the size, but trusting the hardware
>> between map and unmap...)
> 
> Please see my patch series of fixes:
> 
> http://www.spinics.net/lists/netdev/msg248076.html

Which need to be resubmitted with feedback intergrated.

I knew your series existed, but Kyle submitted a fix in the correct
format meanwhile so I applied it.
