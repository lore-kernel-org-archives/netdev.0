From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Mon, 22 Sep 2008 04:21:57 +0400
Message-ID: <20080922002153.GC1878@2ka.mipt.ru>
References: <1221387956.9204.7.camel@fry> <20080921.010458.216237442.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:56708 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585AbYIVAXC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Sep 2008 20:23:02 -0400
Content-Disposition: inline
In-Reply-To: <20080921.010458.216237442.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 01:04:58AM -0700, David Miller (davem@davemloft.net) wrote:
> Applications which work over datagram protocols must perform their own
> segmentation.  It is not like doing a send over a stream protocol like
> TCP, where you can use whatever length you want for send calls and
> segmentation is done for the application.

But isn't the whole idea of the sendfile() is to send a file no matter
what underlying media is?

> If you look, this is what things like NFS using SUNRPC over UDP do.
> They have a transmission unit for the data transfer and use that for
> each "send".

That's maybe because udp_sendpage() does not support sending pending
data if new packet is too big to attach?

-- 
	Evgeniy Polyakov
