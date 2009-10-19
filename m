From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fix TCP_DEFER_ACCEPT retrans calculation
Date: Mon, 19 Oct 2009 22:16:05 +0200
Message-ID: <4ADCC905.1000109@gmail.com>
References: <Pine.LNX.4.58.0910192304060.2971@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59260 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757333AbZJSUQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 16:16:07 -0400
In-Reply-To: <Pine.LNX.4.58.0910192304060.2971@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov a =E9crit :
> 	Fix TCP_DEFER_ACCEPT conversion between seconds and
> retransmission to match the TCP SYN-ACK retransmission periods
> because the time is converted to such retransmissions. The old
> algorithm selects one more retransmission in some cases. Allow
> up to 255 retransmissions.
>=20
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


Note: 255 retransmits translates to 30069 seconds.
