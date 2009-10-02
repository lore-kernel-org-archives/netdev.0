From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Use sk_mark for routing lookup in more places
Date: Fri, 02 Oct 2009 08:08:23 +0200
Message-ID: <4AC598D7.9080900@gmail.com>
References: <200910011814.47689.atis@mikrotik.com>	<4AC4D90E.3040008@gmail.com> <20091001.151823.263194343.davem@davemloft.net> <4AC58C46.8080408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, atis@mikrotik.com,
	panther@balabit.hu, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51878 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756720AbZJBGIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 02:08:34 -0400
In-Reply-To: <4AC58C46.8080408@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Here is a followup on this area, thanks.
>=20
> [RFC] af_packet: fill skb->mark at xmit
>=20
> skb->mark may be used by classifiers, so fill it in case user=20
> set a SO_MARK option on socket.
>=20

Maybe a more generic way to handle this for various protocols
would be to fill skb->mark in sock_alloc_send_pskb()


