From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v2.6.26] gianfar: Determine TBIPA value dynamically
Date: Fri, 11 Apr 2008 10:31:25 -0500
Message-ID: <20080411153125.GA2588@loki.buserror.net>
References: <1207870471-3601-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	linuxppc-dev@ozlabs.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:52434 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759893AbYDKPbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 11:31:08 -0400
Content-Disposition: inline
In-Reply-To: <1207870471-3601-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 10, 2008 at 06:34:31PM -0500, Andy Fleming wrote:
>  
> +	/*
> +	 * This is mildly evil, but so is our hardware for doing this.
> +	 * Also, we have to cast back to struct gfar_mii because of
> +	 * definition weirdness done in gianfar.h.
> +	 */
> +	enet_regs = (struct gfar __iomem *)
> +		((char *)regs - offsetof(struct gfar, gfar_mii_regs));

Can we use to_container() here?

-Scott
