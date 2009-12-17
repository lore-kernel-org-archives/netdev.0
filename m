From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 12:42:54 +0000
Message-ID: <20091217124254.GB8654@ff.dom.local>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au> <20091217114937.GA30503@gondor.apana.org.au> <20091217120856.GA30774@gondor.apana.org.au> <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:55456 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756390AbZLQMnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 07:43:00 -0500
Received: by fxm21 with SMTP id 21so1842713fxm.21
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 04:42:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 05:57:15PM +0530, Krishna Kumar2 wrote:
> the first resched. I also think the resched in requeue is probably
> not required, since the device will call netif_tx_wake_queue anyway.

IIRC there were mentioned some possibly broken drivers around these
changes. So it would require a little bit of reviewing...

Thanks,
Jarek P.
