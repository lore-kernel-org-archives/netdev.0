From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: Support et131x registers in -d
Date: Thu, 8 Nov 2012 19:25:57 +0000
Message-ID: <1352402757.2771.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1351634243-10265-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Mark Einon <mark.einon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23709 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756661Ab2KHT0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 14:26:00 -0500
In-Reply-To: <1351634243-10265-1-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-30 at 21:57 +0000, Mark Einon wrote:
> The et131x register set contains useful details of RX/TX queues for
> the device. This dumps them with the -d option.
>
> Signed-off-by: Mark Einon <mark.einon@gmail.com>

Applied, thanks.  However:

[...]
> --- /dev/null
> +++ b/et131x.c
> @@ -0,0 +1,120 @@
> +#include <stdio.h>
> +#include <string.h>
> +#include "internal.h"
> +
> +int et131x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
> +{
> +	u32 *reg = (u32 *)regs->data;
> +
> +	fprintf(stdout, "PHY Registers\n");
[...]

In case you need to change the dump format later, it might be worth
adding a version check here.  But if you're confident that you'll only
ever append to the dump format, this should be fine for now.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
