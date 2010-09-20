From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix race in tcp_poll
Date: Mon, 20 Sep 2010 15:42:41 -0700 (PDT)
Message-ID: <20100920.154241.183059064.davem@davemloft.net>
References: <20100920185719.GA13355@gmail.com>
	<1285019646.2323.267.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tdm.code@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58964
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960Ab0ITWmW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Sep 2010 18:42:22 -0400
In-Reply-To: <1285019646.2323.267.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Sep 2010 23:54:06 +0200

> Le lundi 20 septembre 2010 =E0 12:18 -0700, Tom Marshall a =E9crit :
>> If a RST comes in immediately after checking sk->sk_err, tcp_poll wi=
ll
>> return POLLIN but not POLLOUT.  Fix this by checking sk->sk_err at t=
he end
>> of tcp_poll.  Additionally, ensure the correct order of operations o=
n SMP
>> machines with memory barriers.
>>=20
>> Signed-off-by: Tom Marshall <tdm.code@gmail.com>
=2E..
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Maybe this is the last time we can avoid taking socket lock in
> tcp_poll() ;)

:-)  Applied, thanks everyone.
