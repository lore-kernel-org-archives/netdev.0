From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next V1 2/4] net/rps: Protect cpu_rmap.h from double
 inclusion
Date: Thu, 19 Jul 2012 14:53:25 +0100
Message-ID: <1342706005.2617.16.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342686832-21406-1-git-send-email-ogerlitz@mellanox.com>
	 <1342686832-21406-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <oren@mellanox.com>,
	<yevgenyp@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29476 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750942Ab2GSNx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 09:53:29 -0400
In-Reply-To: <1342686832-21406-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 11:33 +0300, Or Gerlitz wrote:
> From: Amir Vadai <amirv@mellanox.com>
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  include/linux/cpu_rmap.h |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/cpu_rmap.h b/include/linux/cpu_rmap.h
> index 473771a..ac3bbb5 100644
> --- a/include/linux/cpu_rmap.h
> +++ b/include/linux/cpu_rmap.h
> @@ -1,3 +1,6 @@
> +#ifndef __LINUX_CPU_RMAP_H
> +#define __LINUX_CPU_RMAP_H
> +
>  /*
>   * cpu_rmap.c: CPU affinity reverse-map support
>   * Copyright 2011 Solarflare Communications Inc.
> @@ -71,3 +74,4 @@ extern void free_irq_cpu_rmap(struct cpu_rmap *rmap);
>  extern int irq_cpu_rmap_add(struct cpu_rmap *rmap, int irq);
>  
>  #endif
> +#endif /* __LINUX_CPU_RMAP_H */

Oops :-/

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
