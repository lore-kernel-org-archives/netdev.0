From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] rps: avoid one atomic in
 enqueue_to_backlog
Date: Mon, 17 May 2010 17:22:49 -0700 (PDT)
Message-ID: <20100517.172249.232735178.davem@davemloft.net>
References: <20100506.220759.25136752.davem@davemloft.net>
	<1273209375.2222.37.camel@edumazet-laptop>
	<1273225881.2261.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43075
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752311Ab0ERAWl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 20:22:41 -0400
In-Reply-To: <1273225881.2261.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 07 May 2010 11:51:21 +0200

> Le vendredi 07 mai 2010 =E0 07:16 +0200, Eric Dumazet a =E9crit :
>> Le jeudi 06 mai 2010 =E0 22:07 -0700, David Miller a =E9crit :
>>=20
>> > Looks great, applied, thanks Eric.
>>=20
>> Thanks, I have a followup to avoid one atomic in enqueue phase too ;=
)
>>=20
>=20
> [PATCH net-next-2.6] rps: avoid one atomic in enqueue_to_backlog
>=20
> If CONFIG_SMP=3Dy, then we own a queue spinlock, we can avoid the ato=
mic
> test_and_set_bit() from napi_schedule_prep().
>=20
> We now have same number of atomic ops per netif_rx() calls than with
> pre-RPS kernel.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, thanks Eric.
