From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] udp: memory accounting in IPv4
Date: Mon, 10 Dec 2007 17:22:52 +0800
Message-ID: <20071210092252.GA1598@gondor.apana.org.au>
References: <474DB80E.5070403@redhat.com> <474DB930.5080409@redhat.com> <20071201122120.GB14368@gondor.apana.org.au> <47515CCF.3030009@cosmosbay.com> <47549BE2.9080605@redhat.com> <20071204002644.GA28982@gondor.apana.org.au> <47577A72.10205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3919 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751407AbXLJJXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 04:23:11 -0500
Content-Disposition: inline
In-Reply-To: <47577A72.10205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 05, 2007 at 11:28:34PM -0500, Hideo AOKI wrote:
>
> 1. Using sk_forward_alloc and adding socket lock
> 
>    UDP already uses a socket lock to send message. However, it doesn't
>    use the lock to receive message. I wonder if we can also use the
>    lock when sk_forward_alloc is updated in receive processing.
>    I understand performance issue might occur, but ...

Having discussed this with Dave we've agreed that this is the
best way to go.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
