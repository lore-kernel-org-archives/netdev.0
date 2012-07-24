From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Change rt->rt_iif encoding.
Date: Tue, 24 Jul 2012 15:18:01 -0700 (PDT)
Message-ID: <20120724.151801.1576915988616906722.davem@davemloft.net>
References: <20120723.160541.184307938805782289.davem@davemloft.net>
	<20120723.161446.36265037346365173.davem@davemloft.net>
	<500F1E23.7090803@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: nicolas.2p.debian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754554Ab2GXWSE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 18:18:04 -0400
In-Reply-To: <500F1E23.7090803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>
Date: Wed, 25 Jul 2012 00:13:55 +0200

> - From the af_packet point of view, is was "the real original device
> - that received the packet".
>=20
> As bonding don't use orig_dev anymore, the remaining meaning should
> logically be "the real original device that received the packet". But
> as __netif_receive_skb() is recursively called in many cases, setting
> orig_dev to something new every time, this meaning is probably mostly
> inconsistent. As such, it sounds appropriate to remove orig_dev and
> use skb_iif instead.

I don't think we can, otherwise people who set po->origdev will no
longer get what they expect.

=46or the simpler cases of bonding and VLANs, it does currently behaved
as expected.

That's why I left it alone.
