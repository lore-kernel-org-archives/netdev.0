From: alekcejk@googlemail.com
Subject: Re: Re: Re: Re: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Wed, 15 Feb 2012 17:05:36 +0200
Message-ID: <2414604.1vsFa6H21P@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <2687521.3ztN17SHUf@localhost.localdomain> <CADVnQymT6saSSmUmT7BUShfQFoJ+u4JMQ=F2bhRv4vB_Pzj=9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62439 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034Ab2BOPFv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 10:05:51 -0500
Received: by bkcjm19 with SMTP id jm19so1015960bkc.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 07:05:50 -0800 (PST)
In-Reply-To: <CADVnQymT6saSSmUmT7BUShfQFoJ+u4JMQ=F2bhRv4vB_Pzj=9Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=F7 =D3=CF=CF=C2=DD=C5=CE=C9=C9 =CF=D4 =F3=D2=C5=C4=C1 15 =C6=C5=D7=D2=C1=
=CC=D1 2012 09:49:07 =D7=D9 =CE=C1=D0=C9=D3=C1=CC=C9:
> If there was an increase in the number of bytes charged to the socket
> for each skb, without a corresponding increase in TCP receive buffer
> size, that would explain a systematic decrease in receiver window tha=
t
> would cause some paths, like perhaps these, to become
> receiver-window-limited (which is consistent with the symptom of
> stable bandwidth for a given path).
>=20
> Can you please try increasing the default TCP receiver window to see
> if this helps; try this as root on the 3.2 machine:
>=20
> sysctl net.ipv4.tcp_rmem=3D"4096 897664 897664"

The same results after setting this.

>=20
> Basically making the middle number as big as the third number should
> bump up the default receiver window size.
>=20
> neal
