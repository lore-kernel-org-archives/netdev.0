From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 1/1] net:fec: fix WARNING caused by lack of calls to
 dma_mapping_error()
Date: Wed, 13 Nov 2013 21:27:00 +0000
Message-ID: <1384378020.29151.3.camel@bwh-desktop.uk.level5networks.com>
References: <1384311846-4485-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<b20596@freescale.com>
To: Fugang Duan <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43617 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3KMV1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 16:27:13 -0500
In-Reply-To: <1384311846-4485-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 11:04 +0800, Fugang Duan wrote:
[...]
> =============================================
> V2: add net_ratelimit() to limit map err message.
>     use dma_sync_single_for_cpu() instead of dma_map_single().
>     fix the issue that pass DMA addresses to __va() to get virture address.
> V1: initial send
> =============================================
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
[...]

No that's not how it works.  If I were to thoroughly review this (but I
haven't, and I don't have time to) then I might say 'Reviewed-by: Ben
Hutchings' which you could then add to the patch if re-posting it.
Signed-off-by means something different and you must never add it on
behalf of someone else.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
