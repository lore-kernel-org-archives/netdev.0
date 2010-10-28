From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: fix percpu stats accounting
Date: Thu, 28 Oct 2010 11:41:02 -0700 (PDT)
Message-ID: <20101028.114102.112602886.davem@davemloft.net>
References: <1288283634.11523.20.camel@edumazet-laptop>
	<20101028.102917.246527148.davem@davemloft.net>
	<1288291138.2711.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60371
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757804Ab0J1Skj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 14:40:39 -0400
In-Reply-To: <1288291138.2711.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Oct 2010 20:38:58 +0200

> Le jeudi 28 octobre 2010 =E0 10:29 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 28 Oct 2010 18:33:54 +0200
>>=20
>> > Le jeudi 28 octobre 2010 =E0 20:07 +0400, Pavel Emelyanov a =E9cri=
t :
>> >> commit e985aad7 (ip_gre: percpu stats accounting) forgot the fall=
back
>> >> tunnel case (gre0).
>> >>=20
>> >> This is the 4th part of the "foo: fix percpu stats accounting" se=
ries ;)
>> >>=20
>> >> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> >>=20
>> >=20
>> > Indeed, right you are ;)
>> >=20
>> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>>=20
>> Applied.
>=20
>=20
> Hmm, actually patch is buggy, sorry...

I am still able to revert this I think without screwing up
publicly visible history, so I will double check and do the
revert if I can.
