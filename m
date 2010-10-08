From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] remove leftover rcu_read_unlock calls from
 __mkroute_output
Date: Fri, 08 Oct 2010 06:47:58 +0200
Message-ID: <1286513278.6536.470.camel@edumazet-laptop>
References: <1286498918-30636-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61896 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab0JHEsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 00:48:02 -0400
Received: by wyb28 with SMTP id 28so765747wyb.19
        for <netdev@vger.kernel.org>; Thu, 07 Oct 2010 21:48:01 -0700 (PDT)
In-Reply-To: <1286498918-30636-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 octobre 2010 =C3=A0 17:48 -0700, Dimitris Michailidis a =C3=
=A9crit :
> Commit "fib: RCU conversion of fib_lookup()" removed rcu_read_lock() =
from
> __mkroute_output but left a couple of calls to rcu_read_unlock() in t=
here.
> This causes lockdep to complain that the rcu_read_unlock() call in
> __ip_route_output_key causes a lock inbalance and quickly crashes the
> kernel. The below fixes this for me.
>=20
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Dimitris !


