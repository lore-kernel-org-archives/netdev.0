From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] NET: Add ezchip ethernet driver
Date: Wed, 10 Jun 2015 09:54:01 +0200
Message-ID: <1433922841.24094.20.camel@x220>
References: <1433853863-6704-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey.Brodkin@synopsys.com, vgupta@synopsys.com,
	giladb@ezchip.com, cmetcalf@ezchip.com,
	Tal Zilcer <talz@ezchip.com>
To: Noam Camus <noamc@ezchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud2.xs4all.net ([194.109.24.21]:52283 "EHLO
	lb1-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753965AbbFJHyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 03:54:09 -0400
In-Reply-To: <1433853863-6704-1-git-send-email-noamc@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a nit and a question.

On Tue, 2015-06-09 at 15:44 +0300, Noam Camus wrote:
> --- /dev/null
> +++ b/drivers/net/ethernet/ezchip/Kconfig

> +config NET_VENDOR_EZCHIP
> +	bool "EZchip devices"
> +	default y
> +	---help---
> +	  If you have a network (Ethernet) device belonging to this class, say Y
> +	  and read the Ethernet-HOWTO, available from
> +	  <http://www.tldp.org/docs.html#howto>.
> +
> +	  Note that the answer to this question doesn't directly affect the
> +	  kernel: saying N will just cause the configurator to skip all
> +	  the questions about EZchip devices. If you say Y, you will be asked for
> +	  your specific device in the following questions.
> +
> +if NET_VENDOR_EZCHIP
> +
> +config EZCHIP_NPS_LAN
> +	tristate "EZchip NPS LAN support"
> +	default y

It's not common for drivers to default to 'y'. Any specific reason to do
so here?

> +	---help---
> +	  Simple LAN device without multicast support.
> +	  Device performance is not high and may be used for
> +	  debug or management purposes.
> +	  Device supports interrupts for RX and TX(end).
> +	  Device does not support NAPI and also does not support DMA.
> +
> +endif

> --- /dev/null
> +++ b/drivers/net/ethernet/ezchip/nps_enet.c

> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * The full GNU General Public License is included in this distribution in
> + * the file called "COPYING".

This states the license is GPL v2.

> +MODULE_LICENSE("GPL");

And, according to include/linux/module.h, this states the license is GPL
v2 or later. So I think that either the comment at the top of this file
or the ident used in the MODULE_LICENSE() macro needs to change.


Paul Bolle
