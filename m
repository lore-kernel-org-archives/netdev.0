From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Gianfar ethernet drop package
Date: Fri, 24 Aug 2012 20:17:03 +0200
Message-ID: <1345832223.19483.75.camel@edumazet-glaptop>
References: <5037A86E.2000004@efacec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?An=EDbal?= Almeida Pinto <anibal.pinto@efacec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54700 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754092Ab2HXSRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 14:17:07 -0400
Received: by bkwj10 with SMTP id j10so692423bkw.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 11:17:06 -0700 (PDT)
In-Reply-To: <5037A86E.2000004@efacec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-24 at 17:14 +0100, An=C3=ADbal Almeida Pinto wrote:
> Hi,
>=20
> I have an board with a ppc with a 8379, kernel 3.0.39 and with a Gian=
far=20
> Ethernet Controller Version 1.2.
>=20
> When connect the board to office network the number of dropped packet=
s=20
> reported by ifconfig continues to increase.
>=20
> Following the test made at [1] I use tcpdump and when running it the=20
> number of drop packages don't have increased.
>=20
> When executing ethtool eth0 -S it return a rx-dropped-by-kernel !=3D =
0.=20
> And the rest of drop packages
>=20
> Is possible to get info why the packages are dropped?

You receive frames for unknown protocols. So they are dropped.

When running tcpdump, your tcpdump get them, they are not dropped.

So just parse your tcpdump output ?
