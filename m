From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: Fix potential wrong ip_hdr(skb) pointers
Date: Fri, 06 Feb 2009 03:11:42 -0800 (PST)
Message-ID: <20090206.031142.42099131.davem@davemloft.net>
References: <1233914158.21135.11.camel@localhost.localdomain>
	<498C0B42.7080309@cosmosbay.com>
	<1233917362.21135.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51948
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754615AbZBFLLq convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 06:11:46 -0500
In-Reply-To: <1233917362.21135.16.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Fri, 06 Feb 2009 11:49:22 +0100

> On Fri, 2009-02-06 at 11:04 +0100, Eric Dumazet wrote:
> > Jesper Dangaard Brouer a =E9crit :
> > > On Fri, 2009-02-06 at 01:08 -0800, David Miller wrote:
> > >> Please respin this patch of your's with proper commit message
> > >> and signoffs, thanks!
> > >=20
> > > Like the UDP header fix, pskb_may_pull() can potentially
> > > alter the SKB buffer.  Thus the saddr and daddr, pointers
> > > may point to the old skb->data buffer.
> > >=20
> >=20
> > I dont know... daddr and saddr are not pointers but integers.
>=20
> Yes, you are right... its only in the ipv6 code these are pointers
> (which as DaveM mentioned handels it correctly).
>=20
> > Patch makes sense as a cleanup, but ChangeLog seems wrong ?
>=20
> Okay, lets view it as a cleanup... Its upto DaveM if he wants to fix =
the
> commit message (or ask me the correct it, revert and reapply...)

I already pushed the commit out, rebasing the tree is not an
option and a revert is super ugly so it's staying as-is.
