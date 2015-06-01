From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 1/7] net: dsa: add new driver for ar8xxx family
Date: Mon, 01 Jun 2015 10:14:34 +0200
Message-ID: <1433146474.2361.18.camel@x220>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
	 <1432863742-18427-2-git-send-email-mathieu@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, gang.chen.5i5j@gmail.com, jiri@resnulli.us,
	leitec@staticky.com, fabf@skynet.be, alexander.h.duyck@intel.com,
	pavel.nakonechny@skitlab.ru, joe@perches.com, sfeldma@gmail.com,
	nbd@openwrt.org, juhosg@openwrt.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb1-smtp-cloud6.xs4all.net ([194.109.24.24]:55086 "EHLO
	lb1-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932180AbbFAIOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 04:14:43 -0400
In-Reply-To: <1432863742-18427-2-git-send-email-mathieu@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a nit: a license mismatch.

On Thu, 2015-05-28 at 18:42 -0700, Mathieu Olivari wrote:
> --- /dev/null
> +++ b/drivers/net/dsa/ar8xxx.c

> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 and
> + * only version 2 as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.

This states the license is GPL v2.

> +MODULE_LICENSE("GPL");

And this states, according to include/linux/module.h, that the license
is GPL v2 or later. So I think that either the comment at the top of
this file or the ident used in the MODULE_LICENSE() macro needs to
change.


Paul Bolle
