From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH] net: fec: reset rx mode when do suspend/resume or link
 status change
Date: Thu, 27 Jun 2013 21:15:05 +0800
Message-ID: <20130627131503.GC2695@S2101-09.ap.freescale.net>
References: <1372309759-5067-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <b20596@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<R49496@freescale.com>, <stephen@networkplumber.org>
To: Fugang Duan <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db9lp0249.outbound.messaging.microsoft.com ([213.199.154.249]:57368
	"EHLO db9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751819Ab3F0NPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jun 2013 09:15:16 -0400
Content-Disposition: inline
In-Reply-To: <1372309759-5067-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 27, 2013 at 01:09:19PM +0800, Fugang Duan wrote:
> When do suspend/resume, or plug/unplug network cable, or net watchdog
> timeout process, fec_restart reinit the enet group hash table to zero.
> 
> It is not reasonable for this, so re-config the enet group hash table
> when these actions happen.
> 
> Signed-off-by: Fugang Duan  <B38611@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |  153 ++++++++++++++---------------
>  1 files changed, 76 insertions(+), 77 deletions(-)

A forward declaration of set_multicast_list() can simply save these
dramatic diff stat?

Shawn
