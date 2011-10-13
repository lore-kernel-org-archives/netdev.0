From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 19:11:17 +0200
Message-ID: <1318525877.2393.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318521901.2745.18.camel@bwh-desktop>
	 <1318523090.2393.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318523564.2745.32.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49035 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207Ab1JMRLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 13:11:01 -0400
Received: by wwf22 with SMTP id 22so2117274wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 10:11:00 -0700 (PDT)
In-Reply-To: <1318523564.2745.32.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 octobre 2011 =C3=A0 17:32 +0100, Ben Hutchings a =C3=A9crit=
 :

> Fair enough, but please add a comment explaining this.
>=20


What about :

	/* We do our best to align skb_shared_info on a separate cache
	 * line. It usually works because kmalloc(X > CACHE_BYTES) gives
	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
	 */
	size +=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
