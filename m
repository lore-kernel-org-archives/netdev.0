From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Thu, 28 Apr 2011 08:40:25 +0200
Message-ID: <1303972825.2587.684.camel@edumazet-laptop>
References: <loom.20110427T140651-957@post.gmane.org>
	 <1303906910.3166.50.camel@edumazet-laptop>
	 <loom.20110427T142551-736@post.gmane.org>
	 <loom.20110428T083015-693@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ajit <ajitsa_bes@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54362 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754080Ab1D1Gkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 02:40:31 -0400
Received: by wya21 with SMTP id 21so1818607wya.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 23:40:30 -0700 (PDT)
In-Reply-To: <loom.20110428T083015-693@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 28 avril 2011 =C3=A0 06:36 +0000, Ajit a =C3=A9crit :
> Ajit <ajitsa_bes <at> yahoo.com> writes:
>=20
> >=20
> > Eric Dumazet <eric.dumazet <at> gmail.com> writes:
> >=20
> > > Sure, check your syscall returns values, and search for SO_RCVBUF=
 &
> > > SO_SNDBUF   (man 7 socket)
> > >=20
> > > --
> >=20
> > okies..I dont know exactly how to use those but I will google and t=
ry it..
> > will post my result after some time.
> >=20
> > Thank you
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" i=
n
> > the body of a message to majordomo <at> vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >=20
> >=20
>=20
>=20
> hi sir,
> I tried out something as you said.
>=20
> I introduces this lines in my code,
>=20
> getsockopt(s,SOL_SOCKET,SO_RCVBUF,&optval,&optlen);
> printf("The value of optlen is %d\n",optlen);
>=20

Oh well, netdev is really not the place to discussion like that.

int optval;
socklen_t optlen =3D sizeof(optval);
getsockopt(s,SOL_SOCKET,SO_RCVBUF, &optval, &optlen);
printf("The value of optval is %d\n", optval);

> It always displays 4.
>=20
> I really have no idea about it. Do I need to use setsockopt options i=
n my
> receiver code ??
> If so, what difference will it make ??

It makes sure your socket can really receive enough messages (or kernel
drops them)



