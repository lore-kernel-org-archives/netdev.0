From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] Add constants for the ieee 802.15.4/ZigBee stack
Date: Wed, 03 Jun 2009 03:08:26 -0700 (PDT)
Message-ID: <20090603.030826.03512651.davem@davemloft.net>
References: <1244021629-18409-1-git-send-email-dbaryshkov@gmail.com>
	<1244021629-18409-2-git-send-email-dbaryshkov@gmail.com>
	<1244021629-18409-3-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, sfr@canb.auug.org.au,
	slapin@ossfans.org
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45456
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753390AbZFCKI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 06:08:26 -0400
In-Reply-To: <1244021629-18409-3-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Wed,  3 Jun 2009 13:33:45 +0400

> IEEE 802.15.4/ZigBee stack requires several constants to be defined/adjusted.
> 
> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
> Signed-off-by: Sergey Lapin <slapin@ossfans.org>
> ---
>  include/linux/if.h       |    2 ++
>  include/linux/if_arp.h   |    2 ++
>  include/linux/if_ether.h |    2 ++
>  include/linux/socket.h   |    6 +++++-
>  net/core/dev.c           |    6 ++++--
>  net/core/sock.c          |    3 +++
>  6 files changed, 18 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/if.h b/include/linux/if.h
> index 1108f3e..3f574b8 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -68,6 +68,8 @@
>  #define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use */
>  #define IFF_WAN_HDLC	0x200		/* WAN HDLC device		*/
>  
> +#define IFF_IEEE802154_COORD 0x100	/* IEEE802.15.4 PAN coordinator */
> +
>  #define IF_GET_IFACE	0x0001		/* for querying only */
>  #define IF_GET_PROTO	0x0002
>  

This constant isn't used by any of these patches, and it's
value overlaps that of IFF_MASTER_ARPMON  so would need to be
changed anyways.

I didn't check if other things in this patch turn out to
be unused as well, please audit that.
