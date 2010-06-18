From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 8/8] bridge: Fix netpoll support
Date: Fri, 18 Jun 2010 11:06:19 +0800
Message-ID: <4C1AE2AB.50609@redhat.com>
References: <20100611021142.GA24490@gondor.apana.org.au> <E1OMtjm-0006PK-D6@gondolin.me.apana.org.au> <4C1755C1.3060804@redhat.com> <20100617103819.GA1252@gondor.apana.org.au> <4C19FF98.5080105@redhat.com> <20100617105526.GA1440@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Matt Mackall <mpm@selenic.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757183Ab0FRDZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 23:25:53 -0400
In-Reply-To: <20100617105526.GA1440@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/10 18:55, Herbert Xu wrote:
> On Thu, Jun 17, 2010 at 06:57:28PM +0800, Cong Wang wrote:
>>
>> Hmm, I get it now. So this helps to fix problem 3)?
>
> Yes, by allocating real netpoll structures for each device that
> we're polling, instead of sharing a single one amongst all of
> them.
>
> This is also the basis of the solution of the use-after-free bug.
>

Looks reasonable.
Thank you for your patch!
