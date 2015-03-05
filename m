From: Michael Chan <mchan@broadcom.com>
Subject: Re: [PATCH net-next] tg3: use napi_complete_done()
Date: Thu, 5 Mar 2015 14:47:33 -0800
Message-ID: <1425595653.15992.3.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1425580894.5130.263.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:49193 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbbCEWrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 17:47:39 -0500
In-Reply-To: <1425580894.5130.263.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-05 at 10:41 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Using napi_complete_done() instead of napi_complete() allows
> us to use /sys/class/net/ethX/gro_flush_timeout
> 
> GRO layer can aggregate more packets if the flush is delayed a bit,
> without having to set too big coalescing parameters that impact
> latencies.
> 
There is another napi_complete() call when we detect tx errors.  I guess
we can leave that one unconverted as that code path is very rare.
Thanks.

Acked-by: Michael Chan <mchan@broadcom.com>
