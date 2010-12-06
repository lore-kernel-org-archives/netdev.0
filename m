From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] pktgen: adding prefetchw() call
Date: Mon, 06 Dec 2010 08:26:38 +0100
Message-ID: <1291620398.2806.311.camel@edumazet-laptop>
References: <20101206063349.GA6147@Desktop-Junchang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, robert.olsson@its.uu.se,
	john.r.fastabend@intel.com, andy.shevchenko@gmail.com,
	netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37060 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab0LFH0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 02:26:47 -0500
Received: by wwa36 with SMTP id 36so12490197wwa.1
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 23:26:46 -0800 (PST)
In-Reply-To: <20101206063349.GA6147@Desktop-Junchang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 d=C3=A9cembre 2010 =C3=A0 14:33 +0800, Junchang Wang a =C3=A9=
crit :
> We know for sure pktgen is going to write skb->data right after
> *_alloc_skb, causing unnecessary cache misses.
>=20
> Idea is to add a prefetchw() call to prefetch the first cache line
> indicated by skb->data. On systems with Adjacent Cache Line Prefetch,
> it's probably two cache lines are prefetched.
> With this prefetch, pktgen on Intel SR1625 server with two E5530=20
> quad-core processors and a single ixgbe-based NIC went from 8.63Mpps
> to 9.03Mpps, with 4.6% improvement.
>=20
>=20
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


