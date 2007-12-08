From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 'default' vs. 'all'
Date: Sat, 8 Dec 2007 19:23:27 +0800
Message-ID: <20071208112327.GC19431@gondor.apana.org.au>
References: <20071208.000429.66028544.davem@davemloft.net> <20071208.001411.86141788.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2060 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751925AbXLHLXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 06:23:35 -0500
Content-Disposition: inline
In-Reply-To: <20071208.001411.86141788.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 08, 2007 at 12:14:11AM -0800, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>
> One good event to propagate is the NETDEV_UP; if the dirty bit is
> not set when the device is brought up, copy the default values to
> the device.

Yeah I already did that for IPv4 except that for backwards
compatibility it's set on address addition not device up.

I was in the process of doing it for IPv6 too but got distracted
by other things.  I might still have that tree on my hard drive
if anyone is interested.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
