From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 04/18] via-rhine: disable rx_copybreak on archs that don't
 allow unaligned DMA access
Date: Tue, 14 Aug 2007 01:27:20 -0400
Message-ID: <46C13D38.7010701@garzik.org>
References: <200708102105.l7AL5FUp008954@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jailbird@alcatraz.fdf.net,
	ink@jurassic.park.msu.ru, romieu@fr.zoreil.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46913 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753566AbXHNF1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:27:24 -0400
In-Reply-To: <200708102105.l7AL5FUp008954@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Dustin Marquess <jailbird@alcatraz.fdf.net>
> 
> Patch to disable the rx_copybreak feature on hardware architectures that
> don't allow unaligned DMA access.
> 
> #ifdef code taken from tulip_core.c.  Problem pointed out by Ivan
> Kokshaysky.
> 
> Signed-off-by: Dustin Marquess <jailbird@alcatraz.fdf.net>
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/via-rhine.c |    6 ++++++
>  1 files changed, 6 insertions(+)

applied


