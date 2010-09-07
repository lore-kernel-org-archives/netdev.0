From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 07 Sep 2010 06:36:59 +0200
Message-ID: <1283834219.2585.455.camel@edumazet-laptop>
References: <AANLkTi=_heUejVf-wmEcKd910gVtpD7Hr=cZ_cs2Q8n9@mail.gmail.com>
	 <AANLkTike9biiUvAhckJKHCB6dyS4PzHgFFPF5RNEw4PP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?=E3=83=84?= Leandro Melo de Sales <leandroal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64208 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab0IGEhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 00:37:07 -0400
Received: by wyf22 with SMTP id 22so3776409wyf.19
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 21:37:06 -0700 (PDT)
In-Reply-To: <AANLkTike9biiUvAhckJKHCB6dyS4PzHgFFPF5RNEw4PP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 01:20 -0300, =E3=83=84 Leandro Melo d=
e Sales a
=C3=A9crit :
> Hi all,
>    We are facing a not expected behavior (at least for us) from the
> TCP stack under Linux. We need to write 78 bytes per writing using
> write() function. But instead of sending 78 bytes TCP implementation
> in Linux sends 48 bytes and later 30 bytes. We then started to debug
> the implementation, but although we got some progress on this, I have
> decided to ask in this list if someone can anticipate provide me more
> information why TCP is not sending 78 at once, in addition to have an=
y
> clarification about if it is possible to force TCP sends 78 bytes in
> each write() function call.
>    I have tried many alternatives: set TCP_CORK; used socket API to
> write a fixed 78 bytes per write() function call; and so forth). Also=
,
> I know that TCP is a byte-stream protocol and this decision is made b=
y
> many different factors, such as cwd size, mss and so forth, but 78
> bytes is too small to split it in two different packets. Our
> application works as expected under Windows, it sends 78 bytes at
> once.
>=20
>    In this way, any comment from the list regarding this issue will b=
e
> kindly accepted and helpful.


Could you send a tcpdump of such session, with say first 10 packets ?



