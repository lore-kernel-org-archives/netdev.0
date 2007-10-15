From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] NEW EMAC Fix RGMII build error: use
	of_device_is_compatible
Date: Tue, 16 Oct 2007 07:01:13 +1000
Message-ID: <1192482073.11795.33.camel@pasglop>
References: <20071012130445.GA14704@ru.mvista.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Valentine Barshak <vbarshak@ru.mvista.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20071012130445.GA14704@ru.mvista.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-10-12 at 17:04 +0400, Valentine Barshak wrote:
> Fix build RGMII error: use of_device_is_compatible()
> insteadof now deprecated device_is_compatible() function.
> 
> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

> ---
>  drivers/net/ibm_newemac/rgmii.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/rgmii.c linux-2.6/drivers/net/ibm_newemac/rgmii.c
> --- linux-2.6.orig/drivers/net/ibm_newemac/rgmii.c	2007-10-12 16:02:41.000000000 +0400
> +++ linux-2.6/drivers/net/ibm_newemac/rgmii.c	2007-10-12 16:49:07.000000000 +0400
> @@ -251,7 +251,7 @@ static int __devinit rgmii_probe(struct 
>  	}
>  
>  	/* Check for RGMII type */
> -	if (device_is_compatible(ofdev->node, "ibm,rgmii-axon"))
> +	if (of_device_is_compatible(ofdev->node, "ibm,rgmii-axon"))
>  		dev->type = RGMII_AXON;
>  	else
>  		dev->type = RGMII_STANDARD;
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
