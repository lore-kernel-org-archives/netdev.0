From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: Oops in tun: bisected to  Limit amount of queued packets per device
Date: Thu, 23 Apr 2009 12:08:58 +0200
Message-ID: <m2tz4fptqd.fsf@igel.home>
References: <200904090952.01175.borntraeger@de.ibm.com>
	<20090409093817.GA5760@gondor.apana.org.au> <m2ws9c2zs7.fsf@igel.home>
	<20090423001756.GA8556@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:50948 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755872AbZDWKJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 06:09:04 -0400
In-Reply-To: <20090423001756.GA8556@gondor.apana.org.au> (Herbert Xu's message
	of "Thu, 23 Apr 2009 08:17:56 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Wed, Apr 22, 2009 at 10:34:32PM +0200, Andreas Schwab wrote:
>>
>> > This is weird.  It looks like it's dying on the wake_up_interruptible_sync
>> > in tun_sock_write_space.  However, I can't see how that can cause this.
>> 
>> Any news on this?  It is still badly broken in 2.6.30-rc3.
>
> I think the fixes are in Dave's tree, waiting to be pushed.

Thanks, I've found them.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
