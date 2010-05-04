From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net-next: remove useless union keyword
Date: Tue, 04 May 2010 07:12:07 +0200
Message-ID: <1272949927.2407.182.camel@edumazet-laptop>
References: <1272942254-14760-1-git-send-email-xiaosuo@gmail.com>
	 <1272949625.2407.177.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:33678 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206Ab0EDFMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 01:12:13 -0400
Received: by bwz9 with SMTP id 9so1864075bwz.29
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 22:12:11 -0700 (PDT)
In-Reply-To: <1272949625.2407.177.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 04 mai 2010 =C3=A0 07:07 +0200, Eric Dumazet a =C3=A9crit :
> Le mardi 04 mai 2010 =C3=A0 11:04 +0800, Changli Gao a =C3=A9crit :
> > remove useless union keyword in rtable, rt6_info and dn_route.
> >=20
> > Since there is only one member in a union, the union keyword isn't =
useful.
> >=20
> > Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> > ----
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I'll respin my dst patch

Scratch my Acked-by, this doesnt even compile...

Changli, you _must_ compile your patches.

You _must_ also state if you did not test them.


  CC      net/ipv6/route.o
net/ipv6/route.c:129: error: unknown field =E2=80=98u=E2=80=99 specifie=
d in initializer
net/ipv6/route.c:130: error: unknown field =E2=80=98dst=E2=80=99 specif=
ied in initializer
net/ipv6/route.c:131: error: unknown field =E2=80=98__refcnt=E2=80=99 s=
pecified in initializer
net/ipv6/route.c:131: warning: braces around scalar initializer
net/ipv6/route.c:131: warning: (near initialization for =E2=80=98ip6_nu=
ll_entry_template.dst.rcu_head.next=E2=80=99)
net/ipv6/route.c:131: warning: initialization makes pointer from intege=
r without a cast
net/ipv6/route.c:132: error: unknown field =E2=80=98__use=E2=80=99 spec=
ified in initializer
net/ipv6/route.c:132: warning: initialization makes pointer from intege=
r without a cast
net/ipv6/route.c:133: error: unknown field =E2=80=98obsolete=E2=80=99 s=
pecified in initializer
net/ipv6/route.c:133: warning: excess elements in struct initializer
net/ipv6/route.c:133: warning: (near initialization for =E2=80=98ip6_nu=
ll_entry_template.dst.rcu_head=E2=80=99)
net/ipv6/route.c:134: error: unknown field =E2=80=98error=E2=80=99 spec=
ified in initializer
net/ipv6/route.c:134: warning: excess elements in struct initializer
net/ipv6/route.c:134: warning: (near initialization for =E2=80=98ip6_nu=
ll_entry_template.dst.rcu_head=E2=80=99)


