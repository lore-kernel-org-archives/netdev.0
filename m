From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: netlink recvmsg() and MSG_TRUNC
Date: Wed, 7 Mar 2007 11:07:35 +1100
Message-ID: <20070307000735.GD13170@gondor.apana.org.au>
References: <E1HOjP1-0003NM-00@gondolin.me.apana.org.au> <20070306.160202.102574506.davem@davemloft.net> <20070307000419.GA13170@gondor.apana.org.au> <20070306.160557.111204912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3150 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030757AbXCGAHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 19:07:37 -0500
Content-Disposition: inline
In-Reply-To: <20070306.160557.111204912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 04:05:57PM -0800, David Miller wrote:
>
> Actually, more accurately it's using PAGE_SIZE. :)

Aha it's you non-i386 people :)

> I see, so the better fix would be to make glibc's
> netlink_request() function start with a getpagesize()'d
> buffer.

Yes that's a good idea.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
