From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 03/13] forcedeth: improve NAPI logic
Date: Fri, 11 May 2007 03:11:04 -0400
Message-ID: <46441708.7020605@garzik.org>
References: <200705110552.l4B5qlHx007795@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu, aabdulla@nvidia.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36234 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751856AbXEKHLK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 03:11:10 -0400
In-Reply-To: <200705110552.l4B5qlHx007795@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Ingo Molnar <mingo@elte.hu>
> 
> Another forcedeth.c thing: i noticed that its NAPI handler does not do
> tx-ring processing.  The patch below implements this - tested on DESC_VER_2
> hardware, with CONFIG_FORCEDETH_NAPI=y.
> 
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> ---
> Auke said:
> 
> the patch needs to be improved.
> 
> The following needs to be done when NAPI is enabled:
> - remove the tx handling within the ISRs
> - mask off the tx interrupts within the ISRs that handle tx processing
> - re-enable tx interrupts within the NAPI handler
> - add tx handling within the NAPI handler (this patch covers it)
> 
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |    8 ++++++++
>  1 file changed, 8 insertions(+)

This was NAK'd at least twice?

It's a half-finished project.  You need to do more, if moving TX from 
irq handler to NAPI.

I'm definitely not applying it, and as its incomplete, it definitely 
isn't suitable for upstream.

	Jeff



