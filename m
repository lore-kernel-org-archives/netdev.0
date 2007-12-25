From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about MAC address change
Date: Tue, 25 Dec 2007 08:53:28 +0800
Message-ID: <20071225005328.GA29077@gondor.apana.org.au>
References: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com> <E1J6RPh-0004mf-00@gondolin.me.apana.org.au> <31436f4a0712240538n1b65c2a8u35109ce4c69a00d5@mail.gmail.com> <1198507860.9642.53.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Shwatrz <dshwatrz@gmail.com>, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1298 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752173AbXLYAxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 19:53:42 -0500
Content-Disposition: inline
In-Reply-To: <1198507860.9642.53.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 24, 2007 at 09:50:59AM -0500, jamal wrote:
>
> Herbert, i agree with you that userspace is the best spot for this[1];
> we unfortunately have precedence already on the kernel sending arps with
> bonding when link status changes (that was added recently).
> So it sounds reasonable to have this patch in the kernel as well.

Well just because we've made a mistake in the past does not mean
that we should repeat it over and over again.  If we keep doing
this the kernel will soon end up as a whole heap of junk.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
