From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: netem: Gilbert, Simple Gilbert, Bernouli loss model broken
Date: Tue, 08 Nov 2011 13:57:37 +0100
Message-ID: <1320757057.3444.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAFXUZ_G7oAT9v1B4NNm5c2nxUpU_-zXNV47XzcyKNKgsDLjQzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Marcus Wermuth <marcus.wermuth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54942 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754175Ab1KHM5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 07:57:42 -0500
Received: by bke11 with SMTP id 11so351828bke.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 04:57:41 -0800 (PST)
In-Reply-To: <CAFXUZ_G7oAT9v1B4NNm5c2nxUpU_-zXNV47XzcyKNKgsDLjQzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 novembre 2011 =C3=A0 12:40 +0100, Marcus Wermuth a =C3=A9cr=
it :
> Hey,
>=20
> I wanted to try the netem extension to setup a loss via Gilbert,
> Simple Gilbert, Bernouli loss model[1]. Kernel support is included
> since several releases. But configuration as demonstrated in [1] does
> not work at all. It seems that the userspace part in iproute is
> missing, the original patch from the authors does not work.
>=20
> Does anybody know about that?
>=20
> Bye, Marcus
>=20
> (I'm not subscribed to netdev-list)
>=20
> [1] http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG

Hi

Stephen Hemminger did the kernel part last February (commit 661b79725
netem: revised correlated loss generator)

But apparently never committed the iproute2 part.

Stephen ?
