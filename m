From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 07/33] m68k: Mac89x0 Ethernet netif updates
Date: Tue, 01 May 2007 16:57:09 -0400
Message-ID: <4637A9A5.60601@pobox.com>
References: <20070501203234.252205858@mail.of.borg> <20070501203331.078826974@mail.of.borg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52252 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161382AbXEAU5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 16:57:16 -0400
In-Reply-To: <20070501203331.078826974@mail.of.borg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geert Uytterhoeven wrote:
> From: Matthias Urlichs <smurf@smurf.noris.de>
> 
> Macintosh CS89x0 Ethernet: Netif updates
> Addition of netif_stop_queue() before transmission by Michael Schmitz
> skb_copy_{from,to}_linear_data() conversion by Geert Uytterhoeven
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>  drivers/net/Kconfig   |    2 -
>  drivers/net/mac89x0.c |   92 ++++++++++++++++++--------------------------------
>  2 files changed, 35 insertions(+), 59 deletions(-)

The ethernet patches I've seen so far look sane to me... ACK.

Since they were addressed to Linus and Andrew, I will presume that one 
of those two penguins will apply your drivers/net/* patches.

	Jeff



