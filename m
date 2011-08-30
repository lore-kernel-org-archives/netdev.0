From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42012] New: regression on 2.6.39.3 with socket/bind;
 still there in 3.0.4
Date: Tue, 30 Aug 2011 22:00:52 +0200
Message-ID: <1314734452.2556.12.camel@edumazet-laptop>
References: <20110830.140733.146208373221522199.davem@davemloft.net>
	 <1314731803.2556.4.camel@edumazet-laptop>
	 <1314733459.2556.10.camel@edumazet-laptop>
	 <20110830.155219.431579142669857208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40016 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab1H3UA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 16:00:56 -0400
Received: by wwf5 with SMTP id 5so6617wwf.1
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 13:00:54 -0700 (PDT)
In-Reply-To: <20110830.155219.431579142669857208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 15:52 -0400, David Miller a =C3=A9cri=
t :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 30 Aug 2011 21:44:19 +0200
>=20
> > Status on FreeBSD 8.1-RELEASE
> >=20
> > bind(AF_UNSPEC) is accepted (converted to AF_INET), only with a 0.0=
=2E0.0
> > address.
> >=20
> > Following code works :
> >=20
> > struct sockaddr_in addr;
> > fd =3D socket(PF_INET, SOCK_STREAM, 0);
> > memset(&addr, 0, sizeof(addr))
> > bind(fd, (struct sockaddr *)&addr, sizeof(addr)); -> 0
> >=20
> > If tried on ipv6 sockets, it doesnt work : bind() returns -1, errno=
=3D47
>=20
> Ok if we could add that 0.0.0.0 check too that would make me feel
> better about this change.

Sure, I will send a patch in a couple of minutes.
