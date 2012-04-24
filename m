From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Tue, 24 Apr 2012 04:25:46 -0400 (EDT)
Message-ID: <20120424.042546.2154907239944513463.davem@davemloft.net>
References: <alpine.DEB.2.00.1204241026410.735@wel-95.cs.helsinki.fi>
	<20120424.041018.1514311596818654005.davem@davemloft.net>
	<alpine.DEB.2.00.1204241113020.735@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, rick.jones2@hp.com, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, maze@google.com,
	ycheng@google.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36959 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab2DXI0I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 04:26:08 -0400
In-Reply-To: <alpine.DEB.2.00.1204241113020.735@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 24 Apr 2012 11:21:18 +0300 (EEST)

> On Tue, 24 Apr 2012, David Miller wrote:
>=20
>> That makes this a non-starter since we must therefore remember all o=
f
>> the SACK boundaries in the original packets.
>=20
> GRO works because TCP tends to use rather constant MSS, right? ...Sin=
ce=20
> ACKs and SACKs are nothing more than reflection of those MSS boundari=
es of=20
> the opposite direction I don't find that as impossible as you do beca=
use=20
> the same kind of "mss" assumption can be applied there. But GRO has m=
ade=20
> this somewhat messier now because the receiver doesn't any more gener=
ate=20
> ACK per MSS or ACK per 2*MSS but that could be "fixed" by offloading =
the=20
> ACK sending when responding to a GROed packet.

We're talking about accumulating ACKs on GRO not data packets.
