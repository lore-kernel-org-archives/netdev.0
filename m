From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 1/2] [TCP]: MTUprobe: receiver window & data available checks fixed
Date: Thu, 22 Nov 2007 23:16:22 +0800
Message-ID: <20071122151622.GA11351@gondor.apana.org.au>
References: <11956608882424-git-send-email-ilpo.jarvinen@helsinki.fi> <11956608882602-git-send-email-ilpo.jarvinen@helsinki.fi> <20071122092729.GA7897@gondor.apana.org.au> <Pine.LNX.4.64.0711221420110.2613@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Heffner <jheffner@psc.edu>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1313 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751897AbXKVPQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2007 10:16:38 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0711221420110.2613@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 22, 2007 at 03:11:35PM +0200, Ilpo J=E4rvinen wrote:
>
> ...We'll be using current MTU sized packets except for the probe unti=
l
> the probe has succeeded, only from that point onward will the new pac=
kets
> will be sent with the larger MTU. If the probe succeeds, all reservat=
ions
> we made here are no longer meaningful or necessary anyway. The point =
is to
> detect failure by having fast recovery triggered by the current MTU s=
ized
> packets that follow the probe, that's because we "know" that those sm=
aller
> packets are not going to be dropped by the path even though an oversi=
ze
> probe would be.

Thanks for the explanation!

I'll apply both patches to net-2.6.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
