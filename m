From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IGMP snooping: set mrouters_only flag for IPv4
 traffic properly
Date: Thu, 16 Jun 2011 23:14:47 -0400 (EDT)
Message-ID: <20110616.231447.1625738654020726451.davem@davemloft.net>
References: <1307933995.2704.11.camel@nausicaa>
	<1308013301.3896.6.camel@nexus.oss.ntt.co.jp>
	<1308013483.3896.9.camel@nexus.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.hengli.com.au, shemminger@vyatta.com,
	netdev@vger.kernel.org, kakuta.hayato@oss.ntt.co.jp
To: fernando@oss.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754886Ab1FQDO4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:14:56 -0400
In-Reply-To: <1308013483.3896.9.camel@nexus.oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fernando Luis V=E1zquez Cao <fernando@oss.ntt.co.jp>
Date: Tue, 14 Jun 2011 10:04:43 +0900

> Upon reception of a IGMP/IGMPv2 membership report the kernel sets the
> mrouters_only flag in a skb that may be a clone of the original skb, =
which
> means that sometimes the bridge loses track of membership report pack=
ets (cb
> buffers are tied to a specific skb and not shared) and it ends up for=
wading
> join requests to the bridge interface.
>=20
> This can cause unexpected membership timeouts and intermitent/permane=
nt loss
> of connectivity as described in RFC 4541 [2.1.1. IGMP Forwarding Rule=
s]:
>=20
>     A snooping switch should forward IGMP Membership Reports only to
>     those ports where multicast routers are attached.
>     [...]
>     Sending membership reports to other hosts can result, for IGMPv1
>     and IGMPv2, in unintentionally preventing a host from joining a
>     specific multicast group.
>=20
>=20
> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> Tested-by: Hayato Kakuta <kakuta.hayato@oss.ntt.co.jp>

Applied.
