From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-yourcall] tcp: fix length used for checksum in a
 reset
Date: Wed, 08 Oct 2008 11:34:42 -0700 (PDT)
Message-ID: <20081008.113442.193702738.davem@davemloft.net>
References: <Pine.LNX.4.64.0810081436560.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: agl@imperialviolet.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754582AbYJHSfG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 14:35:06 -0400
In-Reply-To: <Pine.LNX.4.64.0810081436560.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 8 Oct 2008 14:45:35 +0300 (EEST)

>=20
> While looking for some common code I came across difference
> in checksum calculation between tcp_v6_send_(reset|ack) I
> couldn't explain. I checked both v4 and v6 and found out that
> both seem to have the same "feature". I couldn't find anything
> in rfc nor anywhere else which would state that md5 option
> should be ignored like it was in case of reset so I came to
> a conclusion that this is probably a genuine bug. I suspect
> that addition of md5 just was fooled by the excessive
> copy-paste code in those functions and the reset part was
> never tested well enough to find out the problem.
>=20
> I don't see any urge to put this to net-2.6 right before
> 2.6.27 considering it has been broken for ages without anybody
> noticing (considering the Linus' new always-been-like-that-
> but-now-just-enforced rule :-)).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks for finding and fixing this bug, applied to net-next-2.6
