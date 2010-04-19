From: David Miller <davem@davemloft.net>
Subject: Re: tip: origin tree build failure, [patch] fix isdn/gigaset build
 failure
Date: Mon, 19 Apr 2010 10:33:04 -0700 (PDT)
Message-ID: <20100419.103304.35342954.davem@davemloft.net>
References: <20100419.003857.260094283.davem@davemloft.net>
	<20100419172731.GA4358@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tilman@imap.cc, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60711
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750706Ab0DSRdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 13:33:00 -0400
In-Reply-To: <20100419172731.GA4358@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 19 Apr 2010 19:27:31 +0200

> Introduced by commit b91ecb00 that got pushed out today. That change removed 
> an implicit sched.h inclusion that came in via slab.h.
> 
> The patch below fixes it by adding the sched.h dependency.

Thanks Ingo, Linus please apply:

Acked-by: David S. Miller <davem@davemloft.net>

> 	Ingo
> 
> diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
> index f6f45f2..a3aa17f 100644
> --- a/drivers/isdn/gigaset/common.c
> +++ b/drivers/isdn/gigaset/common.c
> @@ -16,6 +16,7 @@
>  #include "gigaset.h"
>  #include <linux/module.h>
>  #include <linux/moduleparam.h>
> +#include <linux/sched.h>
>  
>  /* Version Information */
>  #define DRIVER_AUTHOR "Hansjoerg Lipp <hjlipp@web.de>, Tilman Schmidt <tilman@imap.cc>, Stefan Eilers"
