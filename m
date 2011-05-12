From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 03/15] ehea: Remove force_irq logic in napi poll routine
Date: Wed, 11 May 2011 19:31:10 -0700
Message-ID: <1305167470.6124.10.camel@Joe-Laptop>
References: <20110512005213.897432612@samba.org>
	 <20110512005622.766206152@samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com, netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1503 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840Ab1ELCbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 22:31:11 -0400
In-Reply-To: <20110512005622.766206152@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-12 at 10:52 +1000, Anton Blanchard wrote:
> commit 18604c548545 (ehea: NAPI multi queue TX/RX path for SMP) added
> driver specific logic for exiting napi mode. I'm not sure what it was
> trying to solve and it should be up to the network stack to decide when
> we are done polling so remove it.
> Signed-off-by: Anton Blanchard <anton@samba.org>

> +++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:51.960153456 +1000
> @@ -937,18 +936,13 @@ static int ehea_poll(struct napi_struct
[]
> +	while ((rx != budget)) {

one level of parentheses is enough.


