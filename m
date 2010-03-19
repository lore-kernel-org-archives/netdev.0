From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: speedup netdev_set_master()
Date: Thu, 18 Mar 2010 22:36:58 -0700 (PDT)
Message-ID: <20100318.223658.241427584.davem@davemloft.net>
References: <1268955460.2894.207.camel@edumazet-laptop>
	<20100318.222226.191403090.davem@davemloft.net>
	<1268976491.2894.221.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750705Ab0CSFgg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 01:36:36 -0400
In-Reply-To: <1268976491.2894.221.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Mar 2010 06:28:11 +0100

> Le jeudi 18 mars 2010 =E0 22:22 -0700, David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Fri, 19 Mar 2010 00:37:40 +0100
>>=20
>> > We currently force a synchronize_net() in netdev_set_master()
>> >=20
>> > This seems necessary only when a slave had a master and we dismant=
le it.
>> >=20
>> > In the other case ("ifenslave bond0 ethO"), we dont need this long
>> > delay.
>> >=20
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>=20
>> Depends upon the net-2.6 race fix?
>>=20
>> Thanks for telling me :-/
>=20
> I believe it's not related. It's net-next-2.6 material, for sure :)

It was not an issue of related, but rather "B won't apply cleanly
without A". Even line offsets can make "git apply" reject.
