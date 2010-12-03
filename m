From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: don't reallocate skb->head unless the current
 one hasn't the needed extra size or is shared
Date: Fri, 03 Dec 2010 19:01:39 +0100
Message-ID: <1291399299.2897.572.camel@edumazet-laptop>
References: <1291106926-1898-1-git-send-email-xiaosuo@gmail.com>
	 <20101203.094739.35049271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43855 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab0LCSBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 13:01:44 -0500
Received: by wyb28 with SMTP id 28so9707003wyb.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 10:01:42 -0800 (PST)
In-Reply-To: <20101203.094739.35049271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 d=C3=A9cembre 2010 =C3=A0 09:47 -0800, David Miller a =C3=
=A9crit :
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Tue, 30 Nov 2010 16:48:46 +0800
>=20
> > skb head being allocated by kmalloc(), it might be larger than what
> > actually requested because of discrete kmem caches sizes. Before
> > reallocating a new skb head, check if the current one has the neede=
d
> > extra size.
> >=20
> > Do this check only if skb head is not shared.
> >=20
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Eric, ACK?

Yes :)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !


