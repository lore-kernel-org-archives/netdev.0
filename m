From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Thu, 10 Jan 2008 11:01:53 +1100
Message-ID: <E1JCkrp-0000vX-00@gondolin.me.apana.org.au>
References: <alpine.BSF.1.00.0801091201180.35527@pkunk.americas.sgi.com>
Cc: penguin-kernel@i-love.sakura.ne.jp, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: Brent Casavant <bcasavan@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3584 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754457AbYAJA6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 19:58:35 -0500
In-Reply-To: <alpine.BSF.1.00.0801091201180.35527@pkunk.americas.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brent Casavant <bcasavan@sgi.com> wrote:
> 
>> Did you try MSG_WAITALL flag? See "man 2 recv".
>> A TCP socket handles data in bytes.
>> You cannot complain if the amount received by recv() is smaller than expected
>> unless you use MSG_WAITALL flag.
> 
> Yes. It made no difference, as noted in the comments in the
> provided test program.

The POSIX text for MSG_WAITALL actually says that when used in
conjunction with MSG_PEEK it may not return the full data.

Having said that, I do agree that having TCP and AF_UNIX behave
in the same way is a plus.  However, if you really want this to
happen it would help if you had attached a patch :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
