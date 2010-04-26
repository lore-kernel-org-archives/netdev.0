From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS and forwarding
Date: Mon, 26 Apr 2010 07:15:05 +0200
Message-ID: <1272258905.2069.971.camel@edumazet-laptop>
References: <20100426022415.GA20323@gondor.apana.org.au>
	 <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:36909 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680Ab0DZFPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 01:15:09 -0400
Received: by bwz19 with SMTP id 19so127010bwz.21
        for <netdev@vger.kernel.org>; Sun, 25 Apr 2010 22:15:07 -0700 (PDT)
In-Reply-To: <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 25 avril 2010 =C3=A0 21:44 -0700, Tom Herbert a =C3=A9crit =
:
> > Apart from not using RPS on routers, I suppose people doing
> > forwarding will simply have to maintain a constant RPS table,
> > and forgo its local redirection capabilities.
> >
>=20
> I think you'd want RPS on router (steering packets using hash and CPU
> mask).  Most of your concerns are about RFS (steering by flows), whic=
h
> is probably more appropriate for a server.

We could probably rename RFS parts to RFS to avoid confusion ?



