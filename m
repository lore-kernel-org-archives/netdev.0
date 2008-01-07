From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Mon, 7 Jan 2008 18:32:38 +1100
Message-ID: <20080107073237.GA23026@gondor.apana.org.au>
References: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi> <E1JBJOR-0000jO-00@gondolin.me.apana.org.au> <20080105.231658.168081302.davem@davemloft.net> <Pine.LNX.4.64.0801070908001.17676@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	paul.moore@hp.com, latten@us.ibm.com
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2501 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752042AbYAGHcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 02:32:51 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801070908001.17676@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2008 at 09:13:22AM +0200, Ilpo J=E4rvinen wrote:
>
> There still seems to be good candidates for inline in *.c files, in w=
orst=20
> case I had +172 due to inline removed and ~60 are on +10-+90 range wi=
th=20
> my gcc, later gccs might do better but I definately would just blindl=
y=20
> remove them all. Here's the other end of the list:

Right.  If the inline helps the compiler perform code size optimisation=
s
that it otherwise couldn't then it might be worthwhile.

So when in doubt, check the assembly :)

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
