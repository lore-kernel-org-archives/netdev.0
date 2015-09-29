From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/2] ipv4: Hash-based multipath routing
Date: Mon, 28 Sep 2015 19:33:55 -0700 (PDT)
Message-ID: <20150928.193355.515603960827814980.davem@davemloft.net>
References: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: pch@ordbogen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191AbbI2Cd6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 22:33:58 -0400
In-Reply-To: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Peter N=F8rlund <pch@ordbogen.com>
Date: Wed, 23 Sep 2015 21:49:35 +0200

> When the routing cache was removed in 3.6, the IPv4 multipath algorit=
hm changed
> from more or less being destination-based into being quasi-random per=
-packet
> scheduling. This increases the risk of out-of-order packets and makes=
 it
> impossible to use multipath together with anycast services.
>=20
> This patch series replaces the old implementation with flow-based loa=
d
> balancing based on a hash over the source and destination addresses.

This isn't perfect but it's a significant step in the right direction.
So I'm going to apply this to net-next now and we can make incremental
improvements upon it.

Thanks.
