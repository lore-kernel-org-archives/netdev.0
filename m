From: David Miller <davem@davemloft.net>
Subject: Re: virtio_net: Set correct gso->hdr_len
Date: Mon, 08 Jun 2009 00:22:47 -0700 (PDT)
Message-ID: <20090608.002247.96928247.davem@davemloft.net>
References: <20090604105917.GA28273@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60654
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752336AbZFHHWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:22:45 -0400
In-Reply-To: <20090604105917.GA28273@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 4 Jun 2009 20:59:18 +1000

> Hi:
> 
> virtio_net: Set correct gso->hdr_len
> 
> Through a bug in the tun driver, I noticed that virtio_net is
> producing bogus hdr_len values.  In particular, it only includes
> the IP header in the linear area, and excludes the entire TCP
> header.  This causes the TCP header to be copied twice for each
> packet.  (The bug omitted the second copy :)
> 
> This patch corrects this.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
