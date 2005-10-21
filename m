From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/2] forcedeth: Compile fix forcedeth 0.44
Date: Fri, 21 Oct 2005 17:23:37 -0400
Message-ID: <43595C59.7070204@pobox.com>
References: <432D771D.7050107@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayaz Abdulla <AAbdulla@nvidia.com>, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <432D771D.7050107@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Manfred Spraul wrote:
> Hi,
> 
> forcedeth-0.44 contains a spurious ; in nv_release_txskb. gcc-4 compiles 
> it with a warning, older compilers might reject it.
> The attached onliner fixes that, sorry.
> 
> Signed-off-By: Manfred Spraul <manfred@colorfullife.com>
> 
> 
> ------------------------------------------------------------------------
> 
> --- 2.6/drivers/net/forcedeth.c	2005-09-18 16:12:10.000000000 +0200
> +++ build-2.6/drivers/net/forcedeth.c	2005-09-18 16:14:19.000000000 +0200
> @@ -923,7 +923,7 @@ static int nv_init_ring(struct net_devic
>  static void nv_release_txskb(struct net_device *dev, unsigned int skbnr)
>  {
>  	struct fe_priv *np = get_nvpriv(dev);
> -	struct sk_buff *skb = np->tx_skbuff[skbnr];;
> +	struct sk_buff *skb = np->tx_skbuff[skbnr];
>  	unsigned int j, entry, fragments;

obviously OK, but dropped since the previous patch was dropped
