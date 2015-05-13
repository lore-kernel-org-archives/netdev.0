From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink & rhashtable status
Date: Wed, 13 May 2015 14:20:39 +0800
Message-ID: <20150513062038.GA26944@gondor.apana.org.au>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150513054037.GA26595@gondor.apana.org.au>
 <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:46729 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753807AbbEMGUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:20:46 -0400
Content-Disposition: inline
In-Reply-To: <1431497740.566.129.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 11:15:40PM -0700, Eric Dumazet wrote:
> 
> Trick is to start about 200 threads using getaddrinfo()

When it loses the kernel socket, is it permanent or intermittent?

I'm trying to figure out whether it's the hashtable reader missing
an entry that's there or whether the hashtable has been corrupted
and an entry is gone forever.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
