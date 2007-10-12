From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] NEW EMAC Fix RGMII build error: use
	of_device_is_compatible
Date: Fri, 12 Oct 2007 09:37:01 -0500
Message-ID: <1192199821.3061.41.camel@localhost.localdomain>
References: <20071012130445.GA14704@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Valentine Barshak <vbarshak@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:56875 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654AbXJLOix (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 10:38:53 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9CEcrAE011016
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 10:38:53 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9CEcqeC379866
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 08:38:52 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9CEcqnW001126
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 08:38:52 -0600
In-Reply-To: <20071012130445.GA14704@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-10-12 at 17:04 +0400, Valentine Barshak wrote:
> Fix build RGMII error: use of_device_is_compatible()
> insteadof now deprecated device_is_compatible() function.
> 
> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>

Acked-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

Jeff, this should go into 2.6.24 please.

josh
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

