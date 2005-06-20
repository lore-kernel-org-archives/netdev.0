From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: Re: [PATCH] ax25: endian-annotate ax25_type_trans()
Date: Mon, 20 Jun 2005 11:31:35 +0100
Message-ID: <20050620103135.GC6633@linux-mips.org>
References: <200506200026.04525.adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>
Return-path: <linux-hams-owner@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Content-Disposition: inline
In-Reply-To: <200506200026.04525.adobriyan@gmail.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 20, 2005 at 12:26:04AM +0400, Alexey Dobriyan wrote:

> Subject: [PATCH] ax25: endian-annotate ax25_type_trans()
> Date:	Mon, 20 Jun 2005 00:26:04 +0400
> Cc:	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
> 	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>
> Content-Type: text/plain;
>   charset="us-ascii"

Obviously correct, Dave would you apply this one?

  Ralf
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> Index: linux-sparse/include/net/ax25.h
> ===================================================================
> --- linux-sparse.orig/include/net/ax25.h	2005-06-10 09:24:10.000000000 +0400
> +++ linux-sparse/include/net/ax25.h	2005-06-10 15:03:30.000000000 +0400
> @@ -220,7 +220,7 @@ static __inline__ void ax25_cb_put(ax25_
>  	}
>  }
>  
> -static inline unsigned short ax25_type_trans(struct sk_buff *skb, struct net_device *dev)
> +static inline __be16 ax25_type_trans(struct sk_buff *skb, struct net_device *dev)
>  {
>  	skb->dev      = dev;
>  	skb->pkt_type = PACKET_HOST;

73 de DL5RB op Ralf

--
Loc. JN47BS / CQ 14 / ITU 28 / DOK A21
