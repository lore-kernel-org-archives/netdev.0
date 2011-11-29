From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: is non-inheritance of congestion control algorithm from the
 listen socket a bug or a feature?
Date: Tue, 29 Nov 2011 22:56:26 +0100
Message-ID: <1322603786.2596.36.camel@edumazet-laptop>
References: <1322600212.2596.13.camel@edumazet-laptop>
	 <CAK6E8=djWDn=ZvD0XLxex3vOfsDjCT64k+DwDSNp6+tLbPen2A@mail.gmail.com>
	 <1322603175.2596.31.camel@edumazet-laptop>
	 <20111129.165205.91103035999089185.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ycheng@google.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55325 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab1K2V4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 16:56:33 -0500
Received: by eaak14 with SMTP id k14so3676001eaa.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 13:56:32 -0800 (PST)
In-Reply-To: <20111129.165205.91103035999089185.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 16:52 -0500, David Miller a =C3=A9crit=
 :

> There is really no reason to keep the current behavior.
>=20
> If an application sets the congestion control algorithm on a listenin=
g
> socket to a non-default value, what effect could possibly be intended=
?
>=20
> Congestion control doesn't even come into play at all on a listening
> socket, therefore the only logical expectation is that it inherits to
> the child.
>=20
> The only other logical behavior would be to forbid this operation on =
a
> listening socket, since it has no effect, but that doesn't make any
> sense now does it? :-)

Moreover, an application can use setsockopt(TCP_CONGESTION) before
calling listen() (while socket is still in CLOSE state)
