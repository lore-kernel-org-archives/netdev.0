From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
	non-drops and modifying end-of-line points for skbs
Date: Wed, 11 Mar 2009 13:07:01 -0400
Message-ID: <20090311170701.GA17005@hmsreliant.think-freely.org>
References: <20090303170307.GD1480@hmsreliant.think-freely.org> <20090305210105.GC12835@hmsreliant.think-freely.org> <20090311.091830.152269823.davem@davemloft.net> <49B7E827.3070203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42173 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbZCKRHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 13:07:17 -0400
Content-Disposition: inline
In-Reply-To: <49B7E827.3070203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2009 at 05:34:47PM +0100, Eric Dumazet wrote:
> David Miller a =E9crit :
> > From: Neil Horman <nhorman@tuxdriver.com>
> > Date: Thu, 5 Mar 2009 16:01:05 -0500
> >=20
> >> Ok, as requested, new version of this patch to add in bifurcation =
of kfree_skb
> >> into two versions, one for legitimate kfree's, and one for drops
> >>
> >> Modification Notes:
> >> 1) Renamed kfree_skb_clean to consume_skb, to better identify poin=
ts where we
> >> are finished with an skb
> >>
> >> 2) checkpatch cleanups
> >=20
> > Looks good.
> >=20
> > Respin everything with the requested changes I asked for in #4
> > and I can likely toss this into net-next-2.6, thanks!
>=20
> I was wondering if packets droped at NIC level are handled by "Networ=
k Drop Monitor".
> (See recent discussion about Multicast packet loss)
>=20
> I believe not, maybe I missed something ...
>=20
No, unfortunately, theres no really good way to detect drops at the dri=
ver level
without polling them periodically, which I think is somewhat in opposit=
ion to the
point of this utility.  I'd welcome suggestions however.
Neil

>=20
