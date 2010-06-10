From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Thu, 10 Jun 2010 14:59:15 -0700
Message-ID: <20100610145915.721a86b7@nehalam>
References: <20100610124047.GA16658@gondor.apana.org.au>
	<20100610074912.1303e3da@nehalam>
	<20100610215643.GA22048@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>, Matt Mackall <mpm@selenic.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54811 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756903Ab0FJV7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jun 2010 17:59:21 -0400
In-Reply-To: <20100610215643.GA22048@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jun 2010 07:56:43 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Jun 10, 2010 at 07:49:12AM -0700, Stephen Hemminger wrote:
> > 
> > Thanks for looking at this, and yes the original code does
> > look buggy. Not sure if I like the use of in_irq() to handle the netpoll
> > packets as special case. Is in_irq() really reliable for this?
> 
> Yes because netpoll always calls ndo_start_xmit with IRQs disabled,
> while on the normal TX path IRQs must be enabled (as otherwise
> enabling BH would warn).

Okay, then add a comment where in_irq is used?
