From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio: add missing include to virtio_net.h
Date: Wed, 29 Apr 2009 17:49:43 -0700 (PDT)
Message-ID: <20090429.174943.133929746.davem@davemloft.net>
References: <20090428154654.19053.92829.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48185
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751109AbZD3Att (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:49:49 -0400
In-Reply-To: <20090428154654.19053.92829.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Tue, 28 Apr 2009 09:46:54 -0600

[ Grant, please CC: netdev on networking patches, thanks. ]

> virtio_net.h uses the macro ETH_ALEN which is defined in linux/if_ether.h.
> Discovered when hacking on virtio-over-pci patches.
> 
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>

Rusty, ACK?

I haven't been able to get responses from Rusty on virtio net
patches, so if he doesn't start responding soon I'm going to
integrates the fixes I've seen lately as they all look
reasonable to me.

> ---
> 
>  include/linux/virtio_net.h |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 242348b..cec79ad 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -4,6 +4,7 @@
>   * compatible drivers/servers. */
>  #include <linux/types.h>
>  #include <linux/virtio_config.h>
> +#include <linux/if_ether.h>
>  
>  /* The ID for virtio_net */
>  #define VIRTIO_ID_NET	1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
