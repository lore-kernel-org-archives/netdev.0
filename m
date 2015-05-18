From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH net-next v3 2/2] net: Adding support for Cavium ThunderX
 network controller
Date: Mon, 18 May 2015 10:46:37 +0200
Message-ID: <1431938797.2204.12.camel@x220>
References: <1431747401-20847-1-git-send-email-aleksey.makarov@auriga.com>
	 <1431747401-20847-3-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Daney <david.daney@cavium.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Maciej Czekaj <mjc@semihalf.com>,
	Ganapatrao Kulkarni <ganapatrao.kulkarni@caviumnetworks.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>,
	Robert Richter <rrichter@cavium.com>,
	Kamil Rytarowski <kamil@semihalf.com>,
	Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
	Sruthi Vangala <svangala@cavium.com>,
	Robert Richter <rric@kernel.org>,
	linux-arm-kernel@lists.infradead.org
To: Aleksey Makarov <aleksey.makarov@auriga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud6.xs4all.net ([194.109.24.28]:52955 "EHLO
	lb2-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753054AbbERIqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 04:46:44 -0400
In-Reply-To: <1431747401-20847-3-git-send-email-aleksey.makarov@auriga.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a nit: a license mismatch.

On Fri, 2015-05-15 at 20:36 -0700, Aleksey Makarov wrote:
> --- /dev/null
> +++ b/drivers/net/ethernet/cavium/thunder/nic_main.c

> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation; either version 2 of
> + * the License, or (at your option) any later version.

This states the license is GPL v2 or later. (The other files used for
this module contain an identical comment.)

> +MODULE_LICENSE("GPL v2");

And, according to include/linux/module.h, this states the license is
just GPL v2. So I think that either the license used in the comment at
the top of those files or the ident used in the MODULE_LICENSE() macro
needs to change.

Ditto for the thunder_bgx.ko and the nicvf.ko module.

Thanks,


Paul Bolle
