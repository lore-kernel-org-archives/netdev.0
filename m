From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "ip_gre: make ipgre_tunnel_xmit() not parse
 network header as IP unconditionally"
Date: Sat, 16 Mar 2013 23:01:21 -0400 (EDT)
Message-ID: <20130316.230121.871149184534614934.davem@davemloft.net>
References: <1363178269-27553-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yamahata@valinux.co.jp, edumazet@google.com
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934Ab3CQDB0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Mar 2013 23:01:26 -0400
In-Reply-To: <1363178269-27553-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Wed, 13 Mar 2013 14:37:49 +0200

> This reverts commit 412ed94744d16806fbec3bd250fd94e71cde5a1f.
>=20
> The commit is wrong as tiph points to the outer IPv4 header which is
> installed at ipgre_header() and not the inner one which is protocol d=
ependant.
>=20
> This commit broke succesfully opennhrp which use PF_PACKET socket wit=
h
> ETH_P_NHRP protocol. Additionally ssl_addr is set to the link-layer
> IPv4 address. This address is written by ipgre_header() to the skb
> earlier, and this is the IPv4 header tiph should point to - regardles=
s
> of the inner protocol payload.
>=20
> Signed-off-by: Timo Ter=E4s <timo.teras@iki.fi>

Applied, and queued up for -stable, thanks.
