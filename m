From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Wed, 29 Apr 2009 13:18:03 +0400
Message-ID: <20090429091803.GA23463@ioremap.net>
References: <1240751189.5771.19.camel@bender>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Christoph Lameter <cl@linux.com>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:45962 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580AbZD2JSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 05:18:05 -0400
Content-Disposition: inline
In-Reply-To: <1240751189.5771.19.camel@bender>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 26, 2009 at 03:06:29PM +0200, Johann Baudy (johann.baudy@gnu-log.net) wrote:
> +++ Transmission process
> +Those defines are also used for transmission:
> +
> +     #define TP_STATUS_AVAILABLE        0 // Frame is available
> +     #define TP_STATUS_SEND_REQUEST     1 // Frame will be sent on next send()
> +     #define TP_STATUS_SENDING          2 // Frame is currently in transmission
> +     #define TP_STATUS_WRONG_FORMAT     4 // Frame format is not correct
> +
> +First, the kernel initializes all frames to TP_STATUS_AVAILABLE. To send a
> +packet, the user fills a data buffer of an available frame, sets tp_len to
> +current data buffer size and sets its status field to TP_STATUS_SEND_REQUEST.
> +This can be done on multiple frames. Once the user is ready to transmit, it
> +calls send(). Then all buffers with status equal to TP_STATUS_AVAILABLE are

I suppose kernel sends packets with the status field equal to
TP_STATUS_SEND_REQUEST not TP_STATUS_AVAILABLE.

Besides several codying style issues, like placing { on the new line
from the same one, missing space near the operator like if(smth),
switch(smth), things look good.

-- 
	Evgeniy Polyakov
