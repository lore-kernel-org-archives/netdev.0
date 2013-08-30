From: Rob Herring <rob.herring@calxeda.com>
Subject: Re: [PATCH] xgmac: use bufsz not dma_buf_sz in rx_refill
Date: Thu, 29 Aug 2013 22:17:56 -0500
Message-ID: <52200EE4.9020600@calxeda.com>
References: <20130829201151.GJ8764@redacted.bos.redhat.com> <20130829.163437.1817937756134021051.davem@davemloft.net> <20130829203523.GL8764@redacted.bos.redhat.com> <20130829.163835.1514973445858189297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kmcmarti@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp141.iad.emailsrvr.com ([207.97.245.141]:54461 "EHLO
	smtp141.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab3H3DR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:17:58 -0400
In-Reply-To: <20130829.163835.1514973445858189297.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2013 03:38 PM, David Miller wrote:
> From: Kyle McMartin <kmcmarti@redhat.com>
> Date: Thu, 29 Aug 2013 16:35:23 -0400
> 
>> On Thu, Aug 29, 2013 at 04:34:37PM -0400, David Miller wrote:
>>> From: Kyle McMartin <kyle@redhat.com>
>>> Date: Thu, 29 Aug 2013 16:11:51 -0400
>>>
>>>> Noticed while debugging another issue that DMA debug turned up, looks
>>>> like commit ef468d23 missed a case when switching to bufsz instead of
>>>> priv->dma_buf_sz? (tbf, the whole handling of DMA buffers seems slightly
>>>> suspect since we're not tracking the size, but trusting the hardware
>>>> between map and unmap...)
>>>>
>>>> Signed-off-by: Kyle McMartin <kyle@redhat.com>
>>>
>>> Applied and queued up for -stable, thanks.
>>
>> Heh, too fast David, Rob nak'd it. :)
>>
>> Sorry about that.
> 
> If Rob had resubmitted his series in a timely manner this wouldn't
> have happened.

I was giving them more time hoping to have some feedback from Lennert.
Anyways, I've just resubmitted v2 which addresses Ben's comments.

Rob
