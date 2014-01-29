From: =?UTF-8?B?SG9yaWEgR2VhbnTEgw==?= <horia.geanta@freescale.com>
Subject: Re: [PATCH] xfrm: avoid creating temporary SA when there are no listeners
Date: Wed, 29 Jan 2014 11:17:09 +0200
Message-ID: <52E8C715.8040007@freescale.com>
References: <1390986731-12861-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:19177 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751035AbaA2JRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 04:17:36 -0500
In-Reply-To: <1390986731-12861-1-git-send-email-horia.geanta@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/2014 11:12 AM, Horia Geanta wrote:
> In the case when KMs have no listeners, km_query() will fail and
> temporary SAs are garbage collected immediately after their allocation.
> This causes strain on memory allocation, leading even to OOM since
> temporary SA alloc/free cycle is performed for every packet
> and garbage collection does not keep up the pace.
>
> The sane thing to do is to make sure we have audience before
> temporary SA allocation.
>
> Signed-off-by: Horia Geanta<horia.geanta@freescale.com>
> ---
> Resending - initially posted as RFC:
> http://www.spinics.net/lists/netdev/msg268454.html
>
> Please apply.

This is for ipsec-next, sorry for not mentioning in the first place.

Regards,
Horia
