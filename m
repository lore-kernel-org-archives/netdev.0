From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 17/20][BNX2]: Enhance the heartbeat.
Date: Wed, 02 May 2007 03:38:53 -0400
Message-ID: <4638400D.5010306@garzik.org>
References: <1178068656.4820.53.camel@dell>	<46383B00.4080605@garzik.org> <20070502.002426.38687430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56195 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922AbXEBHjV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 03:39:21 -0400
In-Reply-To: <20070502.002426.38687430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Wed, 02 May 2007 03:17:20 -0400
> 
>> Michael Chan wrote:
>>> [BNX2]: Enhance the heartbeat.
>>>
>>> In addition to the periodic heartbeat, we're adding a heartbeat
>>> request interrupt when the heartbeat is late.  This is useful
>>> especially in -rt kernels where the timer frequently runs late.
>>>
>>> Signed-off-by: Michael Chan <mchan@broadcom.com>
>> Should we really be adding code for such a special situation to upstream 
>> code?
>>
>> I lean towards "no", but defer to your and DaveM's judgement here.
> 
> My understanding of this situation is that if the timer is delayed a
> lot, which can happen with the -rt kernel, we don't send the heartbeat
> ping to the chip within the required margin.
> 
> If the margin is not met, the ASF firmware takes this as a signal that
> the host system is down, and does things like reset the network card
> and other things we don't want it to do.

Thanks for the explanation.

My main concern was

* adding code to use a kernel facility
* then, adding code to handle when that kernel facility doesn't work

and also

* adding code for a situation that never occurs in the upstream kernel.

Regards,

	Jeff


