From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] net/tokenring/olympic.c section fixes
Date: Fri, 04 Apr 2008 01:45:59 -0400
Message-ID: <47F5C097.9010801@pobox.com>
References: <20080330224004.GC28445@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59864 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783AbYDDFqD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 01:46:03 -0400
In-Reply-To: <20080330224004.GC28445@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> My previous section fix only turned one section problem into another 
> section problem.
> 
> This patch fixes it for real.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/tokenring/olympic.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> 59aa404d6b07f60a839e06f3dc772c9de63f5eea diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
> index 433c994..df2bbd7 100644
> --- a/drivers/net/tokenring/olympic.c
> +++ b/drivers/net/tokenring/olympic.c
> @@ -117,7 +117,7 @@
>   * Official releases will only have an a.b.c version number format. 
>   */
>  
> -static char version[] __devinitdata = 
> +static char version[] = 
>  "Olympic.c v1.0.5 6/04/02 - Peter De Schrijver & Mike Phillips" ; 
>  
>  static char *open_maj_error[]  = {"No error", "Lobe Media Test", "Physical Insertion",
> @@ -290,7 +290,7 @@ op_disable_dev:
>  	return i;
>  }
>  
> -static int __devinit olympic_init(struct net_device *dev)
> +static int olympic_init(struct net_device *dev)
>  {
>      	struct olympic_private *olympic_priv;
>  	u8 __iomem *olympic_mmio, *init_srb,*adapter_addr;
> @@ -434,7 +434,7 @@ static int __devinit olympic_init(struct net_device *dev)
>  
>  }
>  
> -static int __devinit olympic_open(struct net_device *dev) 
> +static int olympic_open(struct net_device *dev) 
>  {
>  	struct olympic_private *olympic_priv=netdev_priv(dev);
>  	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio,*init_srb;

applied


