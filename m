From: David Miller <davem@davemloft.net>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Thu, 19 Nov 2015 10:48:11 -0500 (EST)
Message-ID: <20151119.104811.1447518072450380661.davem@davemloft.net>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
	<20151119.005318.838757439536205791.davem@davemloft.net>
	<CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lorenzo@google.com, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, edumazet@google.com, ek@google.com,
	dtor@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934149AbbKSPsN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 10:48:13 -0500
In-Reply-To: <CANP3RGcPRzSL06qZB9oewrvN_AUUodnYzXQO=itoK40z64x8Yw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Wed, 18 Nov 2015 23:19:03 -0800

> Privileged userspace can already make these decisions today, whether
> it is by killing processes with open sockets, or by turning interface=
s
> up and down or by reconfiguring the firewall and/or the routing
> rules/tables, or by injecting spoofed TCP reset packets (via tap).
> It's just *very* inconvenient to do and error prone.
>=20
> Another example: privileged userspace could ptrace the userspace apps
> and via code injection call close() on the app's behalf and reopen th=
e
> file descriptor to some null routed destination so it behaves like if
> it was timed out / unreachable.

At least if they do it this way, and someone claims that Linux TCP
behaves outside the spec or improperly, it's not directly because of
any code I am responsible for.

That's the difference, and frankly an important one to me.

If I'm going to give userspace a direct tool by which to do things,
then it's suddenly my responsibility and my problem.
