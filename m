From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net:fec: fix WARNING caused by lack of calls to
 dma_mapping_error()
Date: Thu, 14 Nov 2013 02:12:21 +0000
Message-ID: <1384395141.29151.23.camel@bwh-desktop.uk.level5networks.com>
References: <1384392631-2059-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Fugang Duan <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10608 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170Ab3KNCMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 21:12:25 -0500
In-Reply-To: <1384392631-2059-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 09:30 +0800, Fugang Duan wrote:
[...]
> =============================================
> V2: add net_ratelimit() to limit map err message.
>     use dma_sync_single_for_cpu() instead of dma_map_single().
>     fix the issue that pass DMA addresses to __va() to get virture address.
> V1: initial send
> =============================================
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Reviewed-by: Ben Hutchings <ben@decadent.org.uk>
[...]

I'm sorry if I wasn't clear in my previous mail.  The 'Reviewed-by' tag
means someone has reviewed *this version* of the patch and explicitly
said it was good, usually by writing that tag in their reply.  You must
not add it just because someone reviewed and commented on an earlier
version of the patch.

I am not familiar with this driver or hardware so I would have to spend
some time looking at the surrounding code before being sure that it's
OK.  I can't spare that time, and so I don't claim to have given this
patch a full review.  But that's OK as you don't need my approval for
David to apply the patch. :-)

Please re-post without any reference to me.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
