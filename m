From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xgmac: use bufsz not dma_buf_sz in rx_refill
Date: Thu, 29 Aug 2013 16:38:35 -0400 (EDT)
Message-ID: <20130829.163835.1514973445858189297.davem@davemloft.net>
References: <20130829201151.GJ8764@redacted.bos.redhat.com>
	<20130829.163437.1817937756134021051.davem@davemloft.net>
	<20130829203523.GL8764@redacted.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob.herring@calxeda.com, netdev@vger.kernel.org
To: kmcmarti@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585Ab3H2Uih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:38:37 -0400
In-Reply-To: <20130829203523.GL8764@redacted.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kmcmarti@redhat.com>
Date: Thu, 29 Aug 2013 16:35:23 -0400

> On Thu, Aug 29, 2013 at 04:34:37PM -0400, David Miller wrote:
>> From: Kyle McMartin <kyle@redhat.com>
>> Date: Thu, 29 Aug 2013 16:11:51 -0400
>> 
>> > Noticed while debugging another issue that DMA debug turned up, looks
>> > like commit ef468d23 missed a case when switching to bufsz instead of
>> > priv->dma_buf_sz? (tbf, the whole handling of DMA buffers seems slightly
>> > suspect since we're not tracking the size, but trusting the hardware
>> > between map and unmap...)
>> > 
>> > Signed-off-by: Kyle McMartin <kyle@redhat.com>
>> 
>> Applied and queued up for -stable, thanks.
> 
> Heh, too fast David, Rob nak'd it. :)
> 
> Sorry about that.

If Rob had resubmitted his series in a timely manner this wouldn't
have happened.

I reverted.
