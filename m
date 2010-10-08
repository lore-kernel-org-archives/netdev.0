From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] remove leftover rcu_read_unlock calls from
 __mkroute_output
Date: Fri, 08 Oct 2010 10:51:26 -0700 (PDT)
Message-ID: <20101008.105126.48494137.davem@davemloft.net>
References: <1286498918-30636-1-git-send-email-dm@chelsio.com>
	<1286513278.6536.470.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dm@chelsio.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48997
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758805Ab0JHRvE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 13:51:04 -0400
In-Reply-To: <1286513278.6536.470.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Oct 2010 06:47:58 +0200

> Le jeudi 07 octobre 2010 =E0 17:48 -0700, Dimitris Michailidis a =E9c=
rit :
>> Commit "fib: RCU conversion of fib_lookup()" removed rcu_read_lock()=
 from
>> __mkroute_output but left a couple of calls to rcu_read_unlock() in =
there.
>> This causes lockdep to complain that the rcu_read_unlock() call in
>> __ip_route_output_key causes a lock inbalance and quickly crashes th=
e
>> kernel. The below fixes this for me.
>>=20
>> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
