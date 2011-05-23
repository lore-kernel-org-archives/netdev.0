From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ping: cleanups ping_v4_unhash()
Date: Mon, 23 May 2011 11:00:47 +0200
Message-ID: <1306141247.2869.10.camel@edumazet-laptop>
References: <1306138981.2869.2.camel@edumazet-laptop>
	 <20110523084308.GA6244@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46976 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771Ab1EWJAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 05:00:50 -0400
Received: by mail-wy0-f174.google.com with SMTP id 21so4027096wya.19
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 02:00:49 -0700 (PDT)
In-Reply-To: <20110523084308.GA6244@albatros>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 mai 2011 =C3=A0 12:43 +0400, Vasiliy Kulikov a =C3=A9crit :
> On Mon, May 23, 2011 at 10:23 +0200, Eric Dumazet wrote:
> > net/ipv4/ping.c: In function =E2=80=98ping_v4_unhash=E2=80=99:
> > net/ipv4/ping.c:140:28: warning: variable =E2=80=98hslot=E2=80=99 s=
et but not used
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Acked-by: Vasiliy Kulikov <segoon@openwall.com>
>=20
> hslot was used for debugging purposes here.
>=20
>=20
> BTW, what gcc version do you use?  I have no warning with 4.4.3
> (Ubuntu 4.4.3-4ubuntu5):
>=20
>     $ make net/ipv4/ping.o
>       CHK     include/linux/version.h
>       CHK     include/generated/utsrelease.h
>       CALL    scripts/checksyscalls.sh
>       CC      net/ipv4/ping.o
>     $
>=20

I got this warning with gcc-4.6.0 on a 32bit (x86) host



