From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 02 Jun 2008 16:19:33 +1000
Message-ID: <E1K33OH-0005QX-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.64.0805311044360.2189@wrl-59.cs.helsinki.fi>
Cc: johnpol@2ka.mipt.ru, ray-lk@madrabbit.org, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, rjw@sisk.pl, akpm@linux-foundation.org
To: ilpo.jarvinen@helsinki.fi (Ilpo J??rvinen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37998 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751495AbYFBGUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 02:20:23 -0400
In-Reply-To: <Pine.LNX.4.64.0805311044360.2189@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
>
> Before:
> tcp    65436      0 lo:5000          lo:59980         ESTABLISHED -

This is what happens before accept(2) is called.  Ingo, please
strace the process that owns the listening socket to make sure
that it is actually calling accept(2).  If it ever stops calling
accept(2) then this is expected behaviour.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
