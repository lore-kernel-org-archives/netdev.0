From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridge: disable snooping if there is no querier
Date: Tue, 06 Aug 2013 08:47:22 -0700
Message-ID: <1375804042.4004.2.camel@edumazet-glaptop>
References: <20130804005227.D17B3660D03@gitolite.kernel.org>
	 <20130806151857.GA25528@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:51576 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754802Ab3HFPrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 11:47:25 -0400
Received: by mail-pa0-f53.google.com with SMTP id lb1so904425pab.26
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 08:47:25 -0700 (PDT)
In-Reply-To: <20130806151857.GA25528@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 11:18 -0400, Dave Jones wrote:
> On Sun, Aug 04, 2013 at 12:52:27AM +0000, Linux Kernel wrote:
>  > Gitweb:     http://git.kernel.org/linus/;a=3Dcommit;h=3Db00589af3b=
04736376f24625ab0b394642e89e29
>  > Commit:     b00589af3b04736376f24625ab0b394642e89e29
>  > Parent:     cf3c4c03060b688cbc389ebc5065ebcce5653e96
>  > Author:     Linus L=C3=BCssing <linus.luessing@web.de>
>  > AuthorDate: Thu Aug 1 01:06:20 2013 +0200
>  > Committer:  David S. Miller <davem@davemloft.net>
>  > CommitDate: Wed Jul 31 17:40:21 2013 -0700
>  >=20
>  >     bridge: disable snooping if there is no querier
>  >    =20
>  >     Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
>  >     Signed-off-by: David S. Miller <davem@davemloft.net>
> =20
>  > diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
>  > @@ -1198,6 +1206,9 @@ static int br_ip6_multicast_query(struct net=
_bridge *br,
>  >  		max_delay =3D mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_m=
rc)) : 1;
>  >  	}
>  > =20
>  > +	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->sadd=
r),
>  > +				    max_delay);
>  > +
>  >  	if (!group)
>  >  		goto out;
>=20
> This addition looks suspect. max_delay looks like it could be uniniti=
alised here.
>=20
> 1178         unsigned long max_delay;
>=20
> ...

fixed in David net tree
