From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 12/21] [TCP]: Introduce per skb fack_counts to retransmit queue
Date: Sun, 2 Dec 2007 22:36:28 +1100
Message-ID: <20071202113628.GA20942@gondor.apana.org.au>
References: <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <20071202062751.GA30937@gondor.apana.org.au> <Pine.LNX.4.64.0712021321410.6477@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4210 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751568AbXLBLgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 06:36:38 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712021321410.6477@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 02, 2007 at 01:29:36PM +0200, Ilpo J=E4rvinen wrote:
>
> Hmm didn't crash for me, probably a silent corruption instead :-(.

It crashed during NIS start-up and I suppose I'm the only still
running NIS :)

> Maybe I could add catch for invalid skb dereferences (those list head=
s) to
> TCP_SKB_CB and tcp_skb_pcount if some DEBUG thing is set. Those two s=
hould
> catch at least 98% of the invalid users.
>=20
> ...Not sure if CONFIG_DEBUG_LIST is right one to use, suggestion welc=
ome.

Sounds OK to me.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
