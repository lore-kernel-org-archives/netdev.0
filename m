From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH] [NET]: Remove PowerPC code from fec.c
Date: Fri, 25 Jan 2008 16:50:52 +0100
Message-ID: <E1JIQpQ-0006Xj-RR@faramir.fjphome.nl>
References: <4799F349.9090102@scram.de>
Cc: galak@kernel.crashing.org, geert@linux-m68k.org, gerg@uclinux.org,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, scottwood@freescale.com,
	vitb@kernel.crashing.org
To: Jochen Friedrich <jochen@scram.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml13.KPNXCHANGE.COM ([213.75.38.113]:5477 "EHLO
	hpsmtp-eml13.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753886AbYAYPu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 10:50:58 -0500
In-reply-To: <4799F349.9090102@scram.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jochen Friedrich wrote:
> +++ b/drivers/net/fec.c
> @@ -23,6 +23,9 @@
>   *
>   * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be)
>   * Copyright (c) 2004-2006 Macq Electronique SA.
> + *
> + * This driver is now only used on ColdFire processors. Remove conditional
> + * Powerpc code. 
>   */

This comment makes sense for a changelog, but IMO it makes no sense at all
to add it to the file.

Cheers,
FJP
