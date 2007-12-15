From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] datagram: mem_scheudle functions
Date: Sat, 15 Dec 2007 22:45:40 +0800
Message-ID: <20071215144540.GA29337@gondor.apana.org.au>
References: <474DB80E.5070403@redhat.com> <474DB90B.9090107@redhat.com> <20071201120946.GA14368@gondor.apana.org.au> <47549B05.5090507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3779 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757523AbXLOOpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 09:45:51 -0500
Content-Disposition: inline
In-Reply-To: <47549B05.5090507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 03, 2007 at 07:10:45PM -0500, Hideo AOKI wrote:
>
> Because we have to call wmem_schedule function in ip_append_data()
> which is used by several protocols both stream and datagram.
> I just thought adding the sk_wmem_schedule() was only way to call
> proper function from ip_append_data().

ip_append_data can't possibly work for stream protocols.  So
which stream protocol is calling it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
