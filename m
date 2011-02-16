From: David Miller <davem@davemloft.net>
Subject: Re: [RFC !!BONUS!! PATCH 6/5] ipv4: Delete routing cache.
Date: Wed, 16 Feb 2011 10:09:35 -0800 (PST)
Message-ID: <20110216.100935.189677289.davem@davemloft.net>
References: <20110209.223939.246547003.davem@davemloft.net>
	<20110215.185534.71133854.davem@davemloft.net>
	<1297842977.3201.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59690
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754063Ab1BPSI7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Feb 2011 13:08:59 -0500
In-Reply-To: <1297842977.3201.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Feb 2011 08:56:17 +0100

> Le mardi 15 f=E9vrier 2011 =E0 18:55 -0800, David Miller a =E9crit :
>> From: David Miller <davem@davemloft.net>
>> Date: Wed, 09 Feb 2011 22:39:39 -0800 (PST)
>>=20
>> >=20
>> > Signed-off-by: David S. Miller <davem@davemloft.net>
>>=20
>> Ok, this patch had one nasty bug:
>>=20
>> > +	if (!err =3D=3D 0)
>>=20
>> Yeah... right.
>>=20
>> I'm actively testing this version at the moment, against net-next-2.=
6,
>> works fine thus far.
>>=20
>> --------------------
>> ipv4: Delete routing cache.
>>=20
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>=20
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I suspect we can zap DST_NOCACHE later ?

Yes, the number of cleanups we can do after this patch is actually
quite large.
