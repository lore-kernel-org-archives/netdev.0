From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 (v2)] [TCP]: Two fixes to new sacktag code
Date: Fri, 30 Nov 2007 01:00:53 +1100
Message-ID: <20071129140053.GA9145@gondor.apana.org.au>
References: <Pine.LNX.4.64.0711281614500.18529@kivilampi-30.cs.helsinki.fi> <Pine.LNX.4.64.0711281847360.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4044 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758139AbXK2OA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 09:00:57 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711281847360.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2007 at 06:52:51PM +0200, Ilpo J=E4rvinen wrote:
> On Wed, 28 Nov 2007, Ilpo J=E4rvinen wrote:
>=20
> > @@ -1575,7 +1575,7 @@ tcp_sacktag_write_queue(struct sock *sk, stru=
ct sk_buff *ack_skb, u32 prior_snd_
> >  			continue;
> >  		}
> >
> > -		if (!before(start_seq, tcp_highest_sack_seq(tp))) {
> > +		if (tp->sacked_out && after(start_seq, tcp_highest_sack_seq(tp))=
) {
>=20
> In this v2, of this patch I'll put !before back here instead, change
> to after is unnecessary here, checking that a sacked skb exists is
> enough to avoid skipping in the problematic head case.

Thanks Ilpo, patch applied to net-2.6.25.

BTW, how's the RB-tree stuff coming along? David wanted it to be in as
early as possible so that it gets the maximum amount of testing before
the next merge window.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
