From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridging with gre tunnel
Date: Mon, 14 Jul 2008 19:45:48 +0800
Message-ID: <E1KIMV2-0007Na-00@gondolin.me.apana.org.au>
References: <487B11D9.7090800@snapgear.com>
Cc: timo.teras@iki.fi, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: philipc@snapgear.com (Philip Craig)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47302 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752735AbYGNLqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 07:46:02 -0400
In-Reply-To: <487B11D9.7090800@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Philip Craig <philipc@snapgear.com> wrote:
> 
> Actually, this change doesn't really belong in GRE either, because
> that forces you to choose between ethernet encapsulation and not.
> It could be a new device that sits on top of GRE and simply does
> ethernet encapsulation then passes it to the raw GRE device.
> That's a lot of infrastructure for something so simple though,
> and I don't think people will want to use both devices at once.

What's the problem with using Ethernet encapsulation on such a
GRE device? If you're referring to the fact that user-space uses
the encapsulation type to determine whether a device is a tunnel,
then we should fix those tools instead.

Rather than trying to resuscitate the ioctl interface, please
create a new extensible netlink interface and make ip(8) use it
where available.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
