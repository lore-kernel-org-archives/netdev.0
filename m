From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/2] powerpc/85xx: add Fman MDIO muxing support to the P4080DS
Date: Tue, 14 Aug 2012 16:45:36 -0500
Message-ID: <5F0028FE-C555-47DE-B69A-888E7322A6E1@kernel.crashing.org>
References: <1344637896-14267-1-git-send-email-timur@freescale.com> <1344637896-14267-2-git-send-email-timur@freescale.com>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Andy Fleming <afleming@freescale.com>,
	Scott Wood <scottwood@freescale.com>, <ddaney.cavm@gmail.com>,
	<linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59779 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756Ab2HNVpv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 17:45:51 -0400
In-Reply-To: <1344637896-14267-2-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 10, 2012, at 5:31 PM, Timur Tabi wrote:

> diff --git a/arch/powerpc/platforms/85xx/corenet_ds.c b/arch/powerpc/platforms/85xx/corenet_ds.c
> index 925b028..a79fc79 100644
> --- a/arch/powerpc/platforms/85xx/corenet_ds.c
> +++ b/arch/powerpc/platforms/85xx/corenet_ds.c
> @@ -106,6 +106,13 @@ static const struct of_device_id of_device_ids[] __devinitconst = {
> 	{
> 		.name		= "handles",
> 	},
> +	{
> +		/*
> +		 * Warning: this entry might need to be located before those
> +		 * for the Fman Ethernet nodes.
> +		 */
> +		.compatible	= "mdio-mux",
> +	},
> 	{}
> };

Under what condition would that be the case?

- k