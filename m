From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
 non-drops and modifying end-of-line points for skbs
Date: Wed, 11 Mar 2009 09:48:43 -0700 (PDT)
Message-ID: <20090311.094843.09768788.davem@davemloft.net>
References: <20090305210105.GC12835@hmsreliant.think-freely.org>
	<20090311.091830.152269823.davem@davemloft.net>
	<49B7E827.3070203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752156AbZCKQs5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 12:48:57 -0400
In-Reply-To: <49B7E827.3070203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 11 Mar 2009 17:34:47 +0100

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

No, it's just a "software network drop monitor"
