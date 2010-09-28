From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Implement Any-IP support for IPv6.
Date: Tue, 28 Sep 2010 13:59:23 -0700 (PDT)
Message-ID: <20100928.135923.59699712.davem@davemloft.net>
References: <1285582022-30787-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, maze@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36921
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752273Ab0I1U7D convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 16:59:03 -0400
In-Reply-To: <1285582022-30787-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 27 Sep 2010 03:07:02 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> AnyIP is the capability to receive packets and establish incoming
> connections on IPs we have not explicitly configured on the machine.
>=20
> An example use case is to configure a machine to accept all incoming
> traffic on eth0, and leave the policy of whether traffic for a given =
IP
> should be delivered to the machine up to the load balancer.
>=20
> Can be setup as follows:
>   ip -6 rule from all iif eth0 lookup 200
>   ip -6 route add local default dev lo table 200
> (in this case for all IPv6 addresses)
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

Does this already work on the ipv4 side?

If not, why only add it to ipv6?
