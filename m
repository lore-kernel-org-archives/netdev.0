From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 23:43:31 +0800
Message-ID: <20071110154331.GA7331@gondor.apana.org.au>
References: <20071110131428.GA6447@gondor.apana.org.au> <20071110.223243.114494952.yoshfuji@linux-ipv6.org> <20071110143325.GA6888@gondor.apana.org.au> <20071110.234854.10674315.yoshfuji@linux-ipv6.org> <20071110145536.GA7024@gondor.apana.org.au> <4735C8E9.4030401@cosmosbay.com> <4735CB59.2050708@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3243 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753760AbXKJPn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 10:43:56 -0500
Content-Disposition: inline
In-Reply-To: <4735CB59.2050708@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 10, 2007 at 04:16:41PM +0100, Eric Dumazet wrote:
>
> It fails to parse /proc/net/netstat , because TcpExt line is bigger than 
> 1024 chars.

Good catch.  Perhaps it's time someone rewrote this in netlink
or add this to ss.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
