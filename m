From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of most of the trees
Date: Thu, 28 May 2015 14:35:45 -0700 (PDT)
Message-ID: <20150528.143545.1946361377143498741.davem@davemloft.net>
References: <20150528220607.67a68696@canb.auug.org.au>
	<20150528.114203.717794268051352731.davem@davemloft.net>
	<1432839075.1556.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	edumazet@google.com
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432839075.1556.4.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 28 May 2015 11:51:15 -0700

> On Thu, 2015-05-28 at 11:42 -0700, David Miller wrote:
>> I've applied the following to net-next, thanks for your report.
>> 
>> ====================
>> [PATCH] treewide: Add missing vmalloc.h inclusion.
>> 
>> All of these files were only building on non-x86 because of
>> the indirect of inclusion of vmalloc.h by, of all things,
>> "net/inet_hashtables.h"
> []
>> diff --git a/crypto/algif_skcipher.c b/crypto/algif_skcipher.c
> []
>> @@ -444,6 +444,7 @@ static int skcipher_recvmsg(struct kiocb *unused, struct socket *sock,
>>  			err = skcipher_wait_for_data(sk, flags);
>>  			if (err)
>>  				goto unlock;
>> +			used = ctx->used;
> 
> huh?

Bogus chunk in my local tree, didn't make it into the final commit I
pushed out.

But thanks for noticing.
