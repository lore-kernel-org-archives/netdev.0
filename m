From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: libpcap and tc filters
Date: Mon, 04 Jul 2011 12:20:09 +0200
Message-ID: <1309774809.2247.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Adam Katz <adamkatz0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33149 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab1GDIUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2011 04:20:08 -0400
Received: by wyg8 with SMTP id 8so3242951wyg.19
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2011 01:20:07 -0700 (PDT)
In-Reply-To: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 04 juillet 2011 =C3=A0 10:38 +0300, Adam Katz a =C3=A9crit :
> Hi Everyone
>=20
> I'm sorry for littering the mailing list with this question, but no
> other place could help me..
>=20
> I'm attempting to use tc to shape traffic sent using libpcap, I'm
> doing this for a research project. I have a classful scheduler with
> several classes, to this scheduler I attach a few filters based on
> destination tcp ports.
>=20
> My problem is this: When sending packets using a normal userland
> socket, the filters work and I see the appropriate traffic entering
> the right class. BUT when sending packets with libpcap, all packets
> end up in the scheduler's default band as if the filters simply refus=
e
> to work.
>=20
> Can anyone suggest a solution?
> --

You already asked this yesterday.

No need to repost.

4th July is not the day many people will answer you...

What gives :

tc -s -d filter show dev eth0



