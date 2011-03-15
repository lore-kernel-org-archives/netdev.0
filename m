From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Tue, 15 Mar 2011 13:36:16 +0100
Message-ID: <20110315123616.GE14548@game.jcrosoft.org>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <1300184096-13937-4-git-send-email-jamie@jamieiles.com>
 <87vczkmy94.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 6.26.mail-out.ovh.net ([46.105.35.144]:44656 "HELO
	26.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with SMTP id S1757621Ab1COMmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 08:42:07 -0400
Content-Disposition: inline
In-Reply-To: <87vczkmy94.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12:14 Tue 15 Mar     , Peter Korsgaard wrote:
> >>>>> "Jamie" == Jamie Iles <jamie@jamieiles.com> writes:
> 
> Hi,
> 
>  Jamie> Both at91 and avr32 defines its own platform data structure for
>  Jamie> the macb driver and both share common structures though at91
>  Jamie> includes a currently unused phy_irq_pin.  Create a common
>  Jamie> eth_platform_data for macb that both at91 and avr32 can use.  In
>  Jamie> future we can use this to support other architectures that use the
>  Jamie> same IP block with the macb driver.
> 
> Nice!
> 
>  Jamie> Signed-off-by: Jamie Iles <jamie@jamieiles.com>
> 
>  Jamie> +++ b/include/linux/platform_data/macb.h
>  Jamie> @@ -0,0 +1,17 @@
>  Jamie> +/*
>  Jamie> + * Copyright (C) 2004-2006 Atmel Corporation
>  Jamie> + *
>  Jamie> + * This program is free software; you can redistribute it and/or modify
>  Jamie> + * it under the terms of the GNU General Public License version 2 as
>  Jamie> + * published by the Free Software Foundation.
>  Jamie> + */
>  Jamie> +#ifndef __MACB_PDATA_H__
>  Jamie> +#define __MACB_PDATA_H__
>  Jamie> +
>  Jamie> +struct eth_platform_data {
> 
> How about at the same time renaming it to something a bit less generic
> like macb_platform_data?
agreed

Best Regards,
J.
> 
> -- 
> Bye, Peter Korsgaard
