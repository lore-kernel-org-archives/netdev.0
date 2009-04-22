From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: Oops in tun: bisected to  Limit amount of queued packets per device
Date: Wed, 22 Apr 2009 22:34:32 +0200
Message-ID: <m2ws9c2zs7.fsf@igel.home>
References: <200904090952.01175.borntraeger@de.ibm.com>
	<20090409093817.GA5760@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:50596 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756626AbZDVUel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 16:34:41 -0400
In-Reply-To: <20090409093817.GA5760@gondor.apana.org.au> (Herbert Xu's message
	of "Thu, 9 Apr 2009 17:38:17 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Thu, Apr 09, 2009 at 09:52:01AM +0200, Christian Borntraeger wrote:
>> 
>> with my kvm test scenario on s390 I get the following oops:
>> Unable to handle kernel pointer dereference at virtual kernel address 0000000400000000
>> Oops: 003b [#1] SMP
>> Modules linked in: kvm dm_multipath sunrpc qeth_l2 dm_mod qeth ccwgroup
>> CPU: 0 Not tainted 2.6.29-kvm-06607-ga317a1e-dirty #8
>> Process kuli (pid: 14827, task: 00000000b3df8138, ksp: 00000000b4703a98)
>> Krnl PSW : 0404e00180000000 0000000000171278 (__lock_acquire+0x3d4/0x191c)
>
> This is weird.  It looks like it's dying on the wake_up_interruptible_sync
> in tun_sock_write_space.  However, I can't see how that can cause this.

Any news on this?  It is still badly broken in 2.6.30-rc3.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
