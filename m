From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 17:43:07 +0100
Message-ID: <1298997787.3284.123.camel@edumazet-laptop>
References: <20110225.112019.48513284.davem@davemloft.net>
	 <20110226005718.GA19889@gondor.apana.org.au>
	 <20110227110205.GE9763@canuck.infradead.org>
	 <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
	 <20110301123519.GA7453@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56063 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397Ab1CAQor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 11:44:47 -0500
Received: by fxm17 with SMTP id 17so4987220fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 08:44:45 -0800 (PST)
In-Reply-To: <20110301123519.GA7453@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 20:35 +0800, Herbert Xu a =C3=A9crit :
> On Mon, Feb 28, 2011 at 07:36:59PM +0800, Herbert Xu wrote:
> > Here are the patches I used.  Please don't them yet as I intend
> > to clean them up quite a bit.
>=20
> OK here is the version ready for merging (please retest them
> though as I have changed things substantially).
>=20
> The main change is that the legacy UDP code path is now gone
> so we use the same UDP header generation whether corking is on
> or off.
>=20
> I will add IPv6 support in a later patch set.
>=20
> Thanks!

=46or the whole patchset :

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Tests were fine on my dev machine.

Thanks


