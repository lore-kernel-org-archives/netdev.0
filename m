From: David Miller <davem@davemloft.net>
Subject: Re: kernel panic when using netns+bridges+tc(netem)
Date: Thu, 06 May 2010 00:54:25 -0700 (PDT)
Message-ID: <20100506.005425.220063166.davem@davemloft.net>
References: <1273128002.2304.4.camel@edumazet-laptop>
	<1273128429.2304.5.camel@edumazet-laptop>
	<1273129187.2304.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: martin.ferrari@gmail.com, arnd@arndb.de, netdev@vger.kernel.org,
	mathieu.lacage@sophia.inria.fr
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55427
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752924Ab0EFHyT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 May 2010 03:54:19 -0400
In-Reply-To: <1273129187.2304.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 May 2010 08:59:47 +0200

> David, this is a stable candidate, once tested and acked, thanks !
>=20
> [PATCH] veth: Dont kfree_skb() after dev_forward_skb()
>=20
> In case of congestion, netif_rx() frees the skb, so we must assume
> dev_forward_skb() also consume skb.
>=20
> Bug introduced by commit 445409602c092
> (veth: move loopback logic to common location)
>=20
> We must change dev_forward_skb() to always consume skb, and veth to n=
ot
> double free it.
>=20
> Bug report : http://marc.info/?l=3Dlinux-netdev&m=3D127310770900442&w=
=3D3
>=20
> Reported-by: Mart=EDn Ferrari <martin.ferrari@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Ugh, applied and queued up for -stable, thanks Eric!
