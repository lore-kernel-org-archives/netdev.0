From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] neigh: probe application via netlink in
 NUD_PROBE
Date: Wed, 26 Feb 2014 15:47:43 -0500 (EST)
Message-ID: <20140226.154743.1440127803884219475.davem@davemloft.net>
References: <20140225.181844.1715731388552960836.davem@davemloft.net>
	<1393407784-8906-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40846 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbaBZUro convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:47:44 -0500
In-Reply-To: <1393407784-8906-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 26 Feb 2014 11:43:04 +0200

> iproute2 arpd seems to expect this as there's code and comments
> to handle netlink probes with NUD_PROBE set. It is used to flush
> the arpd cached mappings.
>=20
> opennhrp instead turns off unicast probes (so it can handle all
> neighbour discovery). Without this change it will not see NUD_PROBE
> probes and cannot reconfirm the mapping. Thus currently neigh entry
> will just fail and can cause few packets dropped until broadcast
> discovery is restarted.
>=20
> Earlier discussion on the subject:
> http://marc.info/?t=3D139305877100001&r=3D1&w=3D2
>=20
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied, thanks a lot Timo.
