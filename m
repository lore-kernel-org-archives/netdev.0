From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
	implementation & Netlink protocol
Date: Thu, 2 Apr 2009 17:39:52 +0800
Message-ID: <20090402093952.GA30553@gondor.apana.org.au>
References: <20090304.030044.163418715.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, nhorman@tuxdriver.com, zbr@ioremap.net,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52150 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935421AbZDBJkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 05:40:14 -0400
Content-Disposition: inline
In-Reply-To: <20090304.030044.163418715.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Catching up with old emails)

David Miller <davem@davemloft.net> wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 04 Mar 2009 11:06:41 +0100
> 
>> It should also be noted that netlink attributes only provide 4 byte
>> alignment. Not sure what the current status of handling unaligned
>> accesses on all architectures is, but something that might have to
>> be taken into consideration.
> 
> Indeed, we have hacks in libnl to work around some of these
> issues :-(

Requiring the use of aligned_u64 instead of __u64 in netlink
structs should help with new data structures, right?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
