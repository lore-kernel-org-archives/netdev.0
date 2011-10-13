From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 18:13:10 +0100
Message-ID: <1318525990.2745.33.camel@bwh-desktop>
References: <1318519581.2393.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318521901.2745.18.camel@bwh-desktop>
	 <1318523090.2393.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1318523564.2745.32.camel@bwh-desktop>
	 <1318525877.2393.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28716 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227Ab1JMRNO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 13:13:14 -0400
In-Reply-To: <1318525877.2393.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-13 at 19:11 +0200, Eric Dumazet wrote:
> Le jeudi 13 octobre 2011 =C3=A0 17:32 +0100, Ben Hutchings a =C3=A9cr=
it :
>=20
> > Fair enough, but please add a comment explaining this.
> >=20
>=20
>=20
> What about :
>=20
> 	/* We do our best to align skb_shared_info on a separate cache
> 	 * line. It usually works because kmalloc(X > CACHE_BYTES) gives
> 	 * aligned memory blocks, unless SLUB/SLAB debug is enabled.
> 	 */
> 	size +=3D SKB_DATA_ALIGN(sizeof(struct skb_shared_info));

Yes, that seems like a good explanation.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
