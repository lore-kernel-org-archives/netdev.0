From: David Miller <davem@davemloft.net>
Subject: Re: TCP connection stops after high load.
Date: Fri, 13 Apr 2007 21:25:23 -0700 (PDT)
Message-ID: <20070413.212523.98702742.davem@davemloft.net>
References: <20070413184111.0ab12e32.dada1@cosmosbay.com>
	<E1HcZlg-0006Bi-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, danielschaffrath@mac.com,
	greearb@candelatech.com, andi@firstfloor.org,
	netdev@vger.kernel.org, bcrl@kvack.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49059
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754176AbXDNEZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 00:25:21 -0400
In-Reply-To: <E1HcZlg-0006Bi-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 14 Apr 2007 14:21:44 +1000

> Eric Dumazet <dada1@cosmosbay.com> wrote:
> > 
> > dev_queue_xmit_nit() is called before attempting to send packet to device.
> > 
> > If device could not accept the packet (hard_start_xmit() returns an error), packet is requeued and retried later.
> > each retry means call ev_queue_xmit_nit() again, so tcpdump/sniffers can 'see' packet transmited several times. 
> 
> This should only happen with LLTX drivers.  In fact, LLTX drivers are
> really more trouble than they're worth.  They should all be rewritten
> to follow the model used in tg3.

Agreed.
