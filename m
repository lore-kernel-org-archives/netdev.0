From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
 dropsrxpackets
Date: Thu, 21 May 2009 00:17:36 -0700 (PDT)
Message-ID: <20090521.001736.16882461.davem@davemloft.net>
References: <4A0DB06D.7000805@cosmosbay.com>
	<20090516124029.GA21086@localhost.localdomain>
	<20090518144622.GB25719@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, jpirko@redhat.com, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45869
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751258AbZEUHRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 03:17:37 -0400
In-Reply-To: <20090518144622.GB25719@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 18 May 2009 10:46:22 -0400

> @@ -0,0 +1,11 @@
> +#ifndef _TRACE_NAPI_H_
> +#define _TRACE_NAPI_H_
> +
> +#include <linux/skbuff.h>
> +#include <linux/tracepoint.h>
> +
> +DECLARE_TRACE(napi_poll,
> +	TP_PROTO(struct napi_struct *napi),
> +	TP_ARGS(napi));
> +
> +#endif

If skbuff.h gets you the declaration for "struct napi_struct"
it's via some indirect accident rather than it actually being
in linux/skbuff.h

Please include the correct headers, thanks.
