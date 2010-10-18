From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] net: cleanups in RX queue allocation
Date: Mon, 18 Oct 2010 22:37:02 +0100
Message-ID: <1287437822.2252.779.camel@achroite.uk.solarflarecom.com>
References: <alpine.DEB.1.00.1010181056590.16238@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, John Fastabend <john.r.fastabend@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57037 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932155Ab0JRVhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 17:37:05 -0400
In-Reply-To: <alpine.DEB.1.00.1010181056590.16238@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-18 at 11:02 -0700, Tom Herbert wrote:
> Clean up in RX queue allocation.  In netif_set_real_num_rx_queues
> return error on attempt to set zero queues, and set
> dev->num_rx_queues if device not registered (similar to TX
> allocation).
[...]

John Fastabend just removed this assignment as it is apparently
undesirable for ixgbe.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

