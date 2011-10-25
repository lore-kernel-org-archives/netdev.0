From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allow CAP_NET_RAW to setsockopt SO_PRIORITY
Date: Tue, 25 Oct 2011 00:58:19 -0400 (EDT)
Message-ID: <20111025.005819.456617923859129015.davem@davemloft.net>
References: <1319518038-28679-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651Ab1JYE6Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 00:58:24 -0400
In-Reply-To: <1319518038-28679-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 24 Oct 2011 21:47:18 -0700

> It is my belief that CAP_NET_ADMIN is and should continue to be about
> configuring the system as a whole, not about configuring per-socket
> or per-packet parameters.
>=20
> Sending and receiving raw packets is what CAP_NET_RAW is all about.
> Hence it makes sense to allow a CAP_NET_RAW process to set the
> priority of sockets and thus packets it sends.

SO_PRIORITY influences the packet scheduler and internal
queueing policies, not just the packet contents that hit
the wire.

Thus CAP_NET_ADMIN is the appropriate capability check.
