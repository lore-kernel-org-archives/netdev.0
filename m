From: David Miller <davem@davemloft.net>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Tue, 15 Jun 2010 21:47:02 -0700 (PDT)
Message-ID: <20100615.214702.57478137.davem@davemloft.net>
References: <1276657139.19249.50.camel@edumazet-laptop>
	<1276657400.19249.53.camel@edumazet-laptop>
	<20100616033336.GA17440@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, paulmck@linux.vnet.ibm.com,
	shemminger@vyatta.com, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, mpm@selenic.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44988
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751173Ab0FPEqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 00:46:50 -0400
In-Reply-To: <20100616033336.GA17440@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 16 Jun 2010 13:33:36 +1000

> On Wed, Jun 16, 2010 at 05:03:20AM +0200, Eric Dumazet wrote:
>>
>> I wonder how these patches were tested, Herbert ?
> 
> You know, not everyone enables RCU debugging...

Even though I'm as guilty as you, I have to agree with Eric that
especially us core folks should be running with the various lock
debugging options on all the time.

Maybe someone should add the RCU debugging config option to
Documentation/SubmitChecklist :-)

> Anyway, this patch should fix the problems you've spotted.

> netpoll: Use correct primitives for RCU dereferencing
> 
> Now that RCU debugging checks for matching rcu_dereference calls
> and rcu_read_lock, we need to use the correct primitives or face
> nasty warnings.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks guys!

