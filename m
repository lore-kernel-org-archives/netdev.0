From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] check the return value of ndo_select_queue()
Date: Mon, 09 Nov 2009 11:02:42 +0100
Message-ID: <4AF7E8C2.90707@gmail.com>
References: <4AF7E221.2040901@gmail.com> <4AF7E5F1.6080608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33616 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754202AbZKIKCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 05:02:41 -0500
In-Reply-To: <4AF7E5F1.6080608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =A8=A6crit :
>=20
> Yes, but this is a _very_ unlikely condition (a bug IMHO), so you cou=
ld use :
>=20
> if (unlikely(queue_index >=3D dev->real_num_tx_queues)) {
> 	...
> }
>=20
> (This unlikely() clause is implied in WARN... macros)
>=20

Also, you want to trigger this message only once, or ratelimit it at le=
ast

