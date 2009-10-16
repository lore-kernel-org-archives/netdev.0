From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/4 v2] net: Use sk_tx_queue_mapping for connected sockets
Date: Fri, 16 Oct 2009 16:07:30 +0200
Message-ID: <4AD87E22.9040500@gmail.com>
References: <20091016072107.24384.17358.sendpatchset@localhost.localdomain> <20091016072132.24384.38301.sendpatchset@localhost.localdomain> <4AD84188.7030804@gmail.com> <OFAE5CC975.C26B600E-ON65257651.00401683-65257651.004721BC@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59292 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757205AbZJPOIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 10:08:17 -0400
In-Reply-To: <OFAE5CC975.C26B600E-ON65257651.00401683-65257651.004721BC@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar2 a =E9crit :

> I wait for tcp_v4_syn_recv_sock to finish and create a connection.
> sk_setup_caps/__sk_dst_set are called for the new socket resulting
> in sk_dst_cache getting set (I cannot set the cache till the
> connection is finished and dst is set). I guess that means that I
> will wait for another skb to come and the response will use skb_tx_ha=
sh
> instead of using the rx recorded.

Well, I see no relation between rx mapping and tx mapping currently.

>=20
> Will this suffice, but if not, is it something I should handle or an
> add-on patch should do instead?
>=20

Your patch is fine, I was only giving ideas for future patches :)



