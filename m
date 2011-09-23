From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Fri, 23 Sep 2011 13:47:34 -0400 (EDT)
Message-ID: <20110923.134734.2267391217120737650.davem@davemloft.net>
References: <1316757739.2560.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hkchu@google.com,
	ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com, jg@freedesktop.org,
	dave.taht@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789Ab1IWRr4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 13:47:56 -0400
In-Reply-To: <1316757739.2560.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Sep 2011 08:02:19 +0200

> While playing with a new ADSL box at home, I discovered that ECN
> blackhole can trigger suboptimal quickack mode on linux : We send one
> ACK for each incoming data frame, without any delay and eventual
> piggyback.
>=20
> This is because TCP_ECN_check_ce() considers that if no ECT is seen o=
n a
> segment, this is because this segment was a retransmit.
>=20
> Refine this heuristic and apply it only if we seen ECT in a previous
> segment, to detect ECN blackhole at IP level.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jamal Hadi Salim <jhs@mojatatu.com>
> CC: Jerry Chu <hkchu@google.com>
> CC: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> CC: Jim Gettys <jg@freedesktop.org>
> CC: Dave Taht <dave.taht@gmail.com>
> ---
> Another possibility is to remove this (not in RFC 3168) heuristic, wh=
at
> do you think ?

Jamal, please give this a look over.  Thanks!
