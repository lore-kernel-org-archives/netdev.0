From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 15:43:38 +0200
Message-ID: <1562329.32T3W12WZD@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <1329280993.2555.21.camel@edumazet-laptop> <CADVnQykxiGBXCKdr=G+T190EA14RnAs0HJ69imsN0h8JKMS4jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61385 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566Ab2BONod convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 08:44:33 -0500
Received: by mail-bk0-f46.google.com with SMTP id jm19so927135bkc.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 05:44:33 -0800 (PST)
In-Reply-To: <CADVnQykxiGBXCKdr=G+T190EA14RnAs0HJ69imsN0h8JKMS4jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=F7 =D3=CF=CF=C2=DD=C5=CE=C9=C9 =CF=D4 =F3=D2=C5=C4=C1 15 =C6=C5=D7=D2=C1=
=CC=D1 2012 01:03:46 =D7=D9 =CE=C1=D0=C9=D3=C1=CC=C9:
> There are some potentially interesting differences in sysctl values:
> > diff -u /tmp/sysctl-a-3.1.txt /tmp/sysctl-a-3.2.txt  | grep mem_def
>=20
> -net.core.wmem_default =3D 114688
> -net.core.rmem_default =3D 114688
> +net.core.wmem_default =3D 163840
> +net.core.rmem_default =3D 163840
>=20
> Can you please try running this as root on the 3.2 kernel and then se=
e
> what sort of performance you get:
>=20
> sysctl net.core.rmem_default=3D114688
>=20
> This should make the 3.2 config closer to the 3.1 config. Should be
> interesting to see if the behavior is more similar when that happens.
>=20
> neal

Nothing changed with download speed after I set net.core.wmem_default =3D=
 114688=20
and net.core.rmem_default =3D 114688.
