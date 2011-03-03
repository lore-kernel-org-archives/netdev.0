From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3] mii: Convert printks to netdev_info
Date: Thu, 03 Mar 2011 12:29:41 -0800
Message-ID: <1299184181.4338.152.camel@Joe-Laptop>
References: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
	 <1b384ead46d062ba189b64649710a5625b7f6a2b.1299086044.git.joe@perches.com>
	 <20110303.122148.245410126.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4080 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594Ab1CCU3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2011 15:29:42 -0500
In-Reply-To: <20110303.122148.245410126.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-03 at 12:21 -0800, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> > Add a bit more data to the output.
> > Convert string speeds to integer.
> > Object size reduced a tiny bit.
> > $ size drivers/net/mii.o*
> >    text	   data	    bss	    dec	    hex	filename
> >    4155	     56	   1000	   5211	   145b	drivers/net/mii.o.new
> >    4184	     56	   1000	   5240	   1478	drivers/net/mii.o.old
> > Signed-off-by: Joe Perches <joe@perches.com>
> Applied.

David, please don't push this yet.

This change is stuffed up somehow, it's
a reversion of the tun.c change.

Let me send you a new/correct patch right now.

