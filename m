From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Tue, 15 Mar 2011 12:14:31 +0100
Message-ID: <87vczkmy94.fsf@macbook.be.48ers.dk>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
	<1300184096-13937-4-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, plagnioj@jcrosoft.com, nicolas.ferre@atmel.com,
	linux-arm-kernel@lists.infradead.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1300184096-13937-4-git-send-email-jamie@jamieiles.com> (Jamie
	Iles's message of "Tue, 15 Mar 2011 10:14:50 +0000")
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

>>>>> "Jamie" == Jamie Iles <jamie@jamieiles.com> writes:

Hi,

 Jamie> Both at91 and avr32 defines its own platform data structure for
 Jamie> the macb driver and both share common structures though at91
 Jamie> includes a currently unused phy_irq_pin.  Create a common
 Jamie> eth_platform_data for macb that both at91 and avr32 can use.  In
 Jamie> future we can use this to support other architectures that use the
 Jamie> same IP block with the macb driver.

Nice!

 Jamie> Signed-off-by: Jamie Iles <jamie@jamieiles.com>

 Jamie> +++ b/include/linux/platform_data/macb.h
 Jamie> @@ -0,0 +1,17 @@
 Jamie> +/*
 Jamie> + * Copyright (C) 2004-2006 Atmel Corporation
 Jamie> + *
 Jamie> + * This program is free software; you can redistribute it and/or modify
 Jamie> + * it under the terms of the GNU General Public License version 2 as
 Jamie> + * published by the Free Software Foundation.
 Jamie> + */
 Jamie> +#ifndef __MACB_PDATA_H__
 Jamie> +#define __MACB_PDATA_H__
 Jamie> +
 Jamie> +struct eth_platform_data {

How about at the same time renaming it to something a bit less generic
like macb_platform_data?

-- 
Bye, Peter Korsgaard
