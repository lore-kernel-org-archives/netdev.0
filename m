From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv2] tun: export underlying socket
Date: Tue, 3 Nov 2009 10:10:30 -0500
Message-ID: <20091103151030.GB8609@gondor.apana.org.au>
References: <20090910125929.GA32593@redhat.com> <20091102172022.GA28247@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Paul Moore <paul.moore@hp.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37752 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751363AbZKCPKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 10:10:38 -0500
Content-Disposition: inline
In-Reply-To: <20091102172022.GA28247@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 02, 2009 at 07:20:22PM +0200, Michael S. Tsirkin wrote:
> Tun device looks similar to a packet socket
> in that both pass complete frames from/to userspace.
> 
> This patch fills in enough fields in the socket underlying tun driver
> to support sendmsg/recvmsg operations, and message flags
> MSG_TRUNC and MSG_DONTWAIT, and exports access to this socket
> to modules.  Regular read/write behaviour is unchanged.
> 
> This way, code using raw sockets to inject packets
> into a physical device, can support injecting
> packets into host network stack almost without modification.
> 
> First user of this interface will be vhost virtualization
> accelerator.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
