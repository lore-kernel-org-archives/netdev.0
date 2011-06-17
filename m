From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IGMP snooping: set mrouters_only flag for IPv6
 traffic properly
Date: Thu, 16 Jun 2011 23:14:53 -0400 (EDT)
Message-ID: <20110616.231453.746182027732338575.davem@davemloft.net>
References: <1307933995.2704.11.camel@nausicaa>
	<1308013301.3896.6.camel@nexus.oss.ntt.co.jp>
	<1308013618.3896.11.camel@nexus.oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.hengli.com.au, shemminger@vyatta.com,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: fernando@oss.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab1FQDQC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:16:02 -0400
In-Reply-To: <1308013618.3896.11.camel@nexus.oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Fernando Luis V=E1zquez Cao <fernando@oss.ntt.co.jp>
Date: Tue, 14 Jun 2011 10:06:58 +0900

> Upon reception of a MGM report packet the kernel sets the mrouters_on=
ly flag
> in a skb that is a clone of the original skb, which means that the br=
idge
> loses track of MGM packets (cb buffers are tied to a specific skb and=
 not
> shared) and it ends up forwading join requests to the bridge interfac=
e.
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

Applied.
