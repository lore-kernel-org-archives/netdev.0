From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 2/2] [TCP] MTUprobe: Cleanup send queue check (no need to loop)
Date: Thu, 22 Nov 2007 19:00:46 +0800
Message-ID: <20071122110046.GA8592@gondor.apana.org.au>
References: <11956608882424-git-send-email-ilpo.jarvinen@helsinki.fi> <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi> <1195660888907-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Heffner <jheffner@psc.edu>, netdev@vger.kernel.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3887 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751604AbXKVLS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 06:18:57 -0500
Content-Disposition: inline
In-Reply-To: <1195660888907-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 06:01:28PM +0200, Ilpo J=E4rvinen wrote:
> The original code has striking complexity to perform a query
> which can be reduced to a very simple compare.
>=20
> FIN seqno may be included to write_seq but it should not make
> any significant difference here compared to skb->len which was
> used previously. One won't end up there with SYN still queued.
>=20
> Use of write_seq check guarantees that there's a valid skb in
> send_head so I removed the extra check.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

OK, this one looks pretty straightforward.  I'll put it in once
we resolve the other patch.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
