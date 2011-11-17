From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regarding Routing cache
Date: Thu, 17 Nov 2011 08:26:58 +0100
Message-ID: <1321514818.3274.37.camel@edumazet-laptop>
References: <CADAe=+Lmp=e3NRH5NOYewJp=XZ0CncPzC-4V=Ct-TEuGjfq3nw@mail.gmail.com>
	 <CADAe=+K8bf_VOe=KszDZRqZnxQH2VFS3C05mpG=RarN+R5BSbA@mail.gmail.com>
	 <1321511214.3274.25.camel@edumazet-laptop>
	 <CADAe=+Jc0YinguPhTuv3sNA2bgEuuTpY9ocE7-_z-uKnsyC7Lw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42108 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752732Ab1KQH1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 02:27:03 -0500
Received: by wyh11 with SMTP id 11so1575893wyh.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 23:27:01 -0800 (PST)
In-Reply-To: <CADAe=+Jc0YinguPhTuv3sNA2bgEuuTpY9ocE7-_z-uKnsyC7Lw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please, no private mails on this discussion. I added back netdev on CC.

Le jeudi 17 novembre 2011 =C3=A0 12:09 +0530, Ajith Adapa a =C3=A9crit =
:
> Hi,
>=20
> Sorry about my naive post regarding the issue.
>=20
> > IPv6 has no routing cache, and wont have one, since we are trying t=
o
> > remove IPv4 routing cache :)
>=20
> But it would have performance issues right as we always check fib
> table for destination route ?
>=20
> Is there any references or posts or material which takes about the
> reason for removing the ipv6 and ipv4 routing caches ?
>=20

routing cache doesnt scale and was difficult to tune in some situations=
=2E

It uses a lot of memory, and doesnt fit in CPU caches.

It was a good solution in the past, but better is to get scalable algo
in the first place.

http://vger.kernel.org/netconf2011.html

http://vger.kernel.org/netconf2011_slides/davem_netconf2011.pdf
