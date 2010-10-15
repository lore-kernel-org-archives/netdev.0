From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 4/8] tg3: Add EEE support
Date: Fri, 15 Oct 2010 15:17:26 +0100
Message-ID: <1287152246.2267.14.camel@achroite.uk.solarflarecom.com>
References: <1287088665-22135-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, andy@greyhouse.net
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53983 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497Ab0JOORa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 10:17:30 -0400
In-Reply-To: <1287088665-22135-5-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-14 at 13:37 -0700, Matt Carlson wrote:
> This patch adds Energy Efficient Ethernet (EEE) support for the 5718
> device ID and the 57765 B0 asic revision.
[...]
> +/* Clause 45 expansion registers */
> +#define TG3_CL45_D7_EEEADV_CAP		0x003c
> +#define TG3_CL45_D7_EEEADV_CAP_100TX	0x0002
> +#define TG3_CL45_D7_EEEADV_CAP_1000T	0x0004

I assume this is going to be a standard register, so I think it should
be defined in <linux/mdio.h>.

> +#define TG3_CL45_D7_EEERES_STAT                0x803e
> +#define TG3_CL45_D7_EEERES_STAT_LP_100TX	0x0002
> +#define TG3_CL45_D7_EEERES_STAT_LP_1000T	0x0004

0x803e not 0x003e?

Also Dave suggested there should be an ethtool interface to control EEE
<http://thread.gmane.org/gmane.linux.network/164141/focus=165143>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

