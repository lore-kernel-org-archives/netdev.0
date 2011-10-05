From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: big picture UDP/IP performance question re 2.6.18 -> 2.6.32
Date: Wed, 05 Oct 2011 08:53:47 +0200
Message-ID: <1317797627.3099.1.camel@edumazet-laptop>
References: <6.2.5.6.2.20111003140010.05a70ed0@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: starlight@binnacle.cx
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6.2.5.6.2.20111003140010.05a70ed0@binnacle.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 03 octobre 2011 =C3=A0 14:02 -0400, starlight@binnacle.cx a =C3=
=A9crit :
> At 06:16 PM 10/3/2011 +0200, Eric Dumazet wrote:
> >
> >It seems you use 4096 2MB hugepages, and your
> >machine has 1GB pages availabe, you could
> >try to use them.
> >
> >(boot cmd : hugepagesz=3D1GB hugepages=3D8 )
>=20
> Tried it and got errno 12 on the segment
> allocations.  None were allocated, though
> the count is six and the largest is exactly
> 1GB.  Don't have time to dig into it.
>=20

Thats pretty normal ;)

With 2MB pages, your segment size must be a 2MB multiple.

With 1GB pages, your segment size must be a .... 1GB multiple.

So only applicable is say you handle one big 8GB segment for example, o=
r
2 4GB segments... Well you see the picture.
