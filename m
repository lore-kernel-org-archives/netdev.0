From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 2/4] packet: Add fanout support.
Date: Wed, 06 Jul 2011 06:48:58 +0200
Message-ID: <1309927738.2545.55.camel@edumazet-laptop>
References: <20110705.203957.1530606132453742271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, victor@inliniac.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53355 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783Ab1GFEtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 00:49:03 -0400
Received: by wyg8 with SMTP id 8so4411050wyg.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 21:49:02 -0700 (PDT)
In-Reply-To: <20110705.203957.1530606132453742271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 05 juillet 2011 =C3=A0 20:39 -0700, David Miller a =C3=A9crit =
:
> Fanouts allow packet capturing to be demuxed to a set of AF_PACKET
> sockets.  Two fanout policies are implemented:
>=20
> 1) Hashing based upon skb->rxhash
>=20
> 2) Pure round-robin
>=20
> An AF_PACKET socket must be fully bound before it tries to add itself
> to a fanout.  All AF_PACKET sockets trying to join the same fanout
> must all have the same bind settings.
>=20
> Fanouts are identified (within a network namespace) by a 16-bit ID.
> The first socket to try to add itself to a fanout with a particular
> ID, creates that fanout.  When the last socket leaves the fanout
> (which happens only when the socket is closed), that fanout is
> destroyed.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


