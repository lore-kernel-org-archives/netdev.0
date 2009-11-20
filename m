From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 23:37:23 +0100
Message-ID: <20091120223723.GA4460@basil.fritz.box>
References: <4B05D8DC.7020907@gmail.com> <87aayg539l.fsf@basil.nowhere.org> <4B07188C.2070808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:38010 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684AbZKTWhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 17:37:21 -0500
Content-Disposition: inline
In-Reply-To: <4B07188C.2070808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2009 at 11:30:36PM +0100, Eric Dumazet wrote:
> Andi Kleen a =E9crit :
> >=20
> > Do you have numbers on this? It seems like a lot of effort to avoid=
 transfering
> > a few cache lines.
>=20
> Lot of efforts ? hmm...

Well lots of code at least. Perhaps I'm old fashioned, but I always lik=
e to have
each code justify its complexity.

It seems like a very narrow special case. Or perhaps this is something =
that
should be a general library function for all allocator users?

> Yes, I know, but slab/slub is already quite optimized :)

Well it still has a lot of problems, other benchmarks suffer too.

-Andi
--=20
ak@linux.intel.com -- Speaking for myself only.
