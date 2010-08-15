From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: raw sockets rewriting IP ID in rare cases.
Date: Sun, 15 Aug 2010 22:47:00 +0200
Message-ID: <1281905220.2942.57.camel@edumazet-laptop>
References: <201008131307.38381.morgon.j.kanter@dartmouth.edu>
	 <20100814.223532.242143460.davem@davemloft.net>
	 <20100815135741.1iud2jvgw0wwg4kw@webmail.dartmouth.edu>
	 <20100815.131359.191392588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Morgon.J.Kanter@Dartmouth.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40674 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab0HOUrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Aug 2010 16:47:06 -0400
Received: by wwj40 with SMTP id 40so5571887wwj.1
        for <netdev@vger.kernel.org>; Sun, 15 Aug 2010 13:47:05 -0700 (PDT)
In-Reply-To: <20100815.131359.191392588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 15 ao=C3=BBt 2010 =C3=A0 13:13 -0700, David Miller a =C3=A9=
crit :
> From: Morgon.J.Kanter@Dartmouth.edu
> Date: Sun, 15 Aug 2010 13:57:41 -0400
>=20
> > Is there a way to turn this behavior off, then, with raw sockets? Z=
ero
> > is the desired ID value.
>=20
> No, there isn't.

Just a note about IP_DF (Dont Fragment) bit.

If set, ID stay 0.

Not sure it can help Morgon.

Jiri Olsa added IP_NODEFRAG option some weeks ago (commit 7b2ff18e),
we probably could implement IP_NOIDENT option for RAW sockets ?



