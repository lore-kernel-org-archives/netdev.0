From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25] [TCP]: Move FRTO checks out from write queue abstraction funcs
Date: Fri, 23 Nov 2007 22:51:08 +0800
Message-ID: <20071123145108.GA20508@gondor.apana.org.au>
References: <Pine.LNX.4.64.0711231422500.24866@kivilampi-30.cs.helsinki.fi> <20071123133428.GK18862@gondor.apana.org.au> <Pine.LNX.4.64.0711231601490.7738@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2212 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753460AbXKWOvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 09:51:11 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711231601490.7738@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 04:14:03PM +0200, Ilpo J=E4rvinen wrote:
>
> The purpose of the tcp_advance_send_head & friends was/is to abstract
> the write queue from the TCP worker code. RB-tree wq can then be put =
in
> place more easily (and I'm hopefully coming to that soon). There are =
some
> other similar functions in tcp.h as well which currently have only a
> single caller. Please don't undo that work while DaveM is away for a =
short
> while :-).

Thanks for the explanation! I'll apply this patch.
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
