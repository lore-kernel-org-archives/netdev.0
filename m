From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Sat, 26 Feb 2011 08:31:24 +0100
Message-ID: <1298705484.2659.126.camel@edumazet-laptop>
References: <20110226005718.GA19889@gondor.apana.org.au>
	 <20110225.181244.104056532.davem@davemloft.net>
	 <20110226024848.GA20993@gondor.apana.org.au>
	 <20110225.190723.39180243.davem@davemloft.net>
	 <20110226031118.GA21270@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	tgraf@infradead.org, therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40628 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab1BZHbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 02:31:33 -0500
Received: by wyg36 with SMTP id 36so2286673wyg.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 23:31:32 -0800 (PST)
In-Reply-To: <20110226031118.GA21270@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 26 f=C3=A9vrier 2011 =C3=A0 11:11 +0800, Herbert Xu a =C3=A9c=
rit :
> On Fri, Feb 25, 2011 at 07:07:23PM -0800, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Sat, 26 Feb 2011 10:48:48 +0800
> >=20
> > > I'm looking at redoing this and the bulk of the work is going to
> > > be restructuring ip_append_data/ip_push_pending_frames so that it
> > > doesn't store the states in sk/inet_sk.
> >=20
> > I suppose you're going to replace that stuff with an on-stack
> > control structure that gets passed around by reference or
> > similar?
>=20
> Either that or have ip_append_data do ip_push_pending_frames
> directly.
>=20
> That function's signature is a mess already and I need to think
> about this a bit more :)
>=20
> Cheers,


UDP CORK is a problem indeed. I wonder who really uses it ?



