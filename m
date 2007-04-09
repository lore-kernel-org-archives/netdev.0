From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [SC92031]: Fix priv->lock context
Date: Mon, 09 Apr 2007 15:01:49 -0400
Message-ID: <461A8D9D.6070604@pobox.com>
References: <20070405114431.GA10972@gondor.apana.org.au> <20070405.095929.79068467.davem@davemloft.net> <20070405215703.GA21219@gondor.apana.org.au> <20070409.115625.08346514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, akpm@linux-foundation.org,
	netdev@vger.kernel.org, adaplas@pol.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57034 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964896AbXDITCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2007 15:02:08 -0400
In-Reply-To: <20070409.115625.08346514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Fri, 6 Apr 2007 07:57:03 +1000
> 
>> On Thu, Apr 05, 2007 at 09:59:29AM -0700, David Miller wrote:
>>> Where is the patch? :-)
>>>
>>> Second time you've done this in two days Herbert, tsk tsk :)))
>> The patch was so easy that it was left as an exercise to the reader :)
>>
>> [SC92031]: Fix priv->lock context
>>
>> The spin_lock calls made in dev->open and dev->close must disable
>> BH since open/close are made in process context.  Conversely, the
>> call in dev->hard_start_xmit does not need to disable BH since it
>> is already executing with BH disabled.
>>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied, either Jeff or myself will make sure this gets into
> Linus's tree.

Sounds like you got this one?

	Jeff



