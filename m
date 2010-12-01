From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 19:24:53 +0100
Message-ID: <1291227893.2856.1039.camel@edumazet-laptop>
References: <AANLkTin6d=t6U28A-r=FznqE+5QuGXwg1tStOw-JXabg@mail.gmail.com>
	 <1291192967.2856.492.camel@edumazet-laptop>
	 <18eaf7d286236427b1632b9af62be513@localhost>
	 <20101201.101809.71122121.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, xiaosuo@gmail.com, wirelesser@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34014 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753690Ab0LASZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 13:25:02 -0500
Received: by wyb28 with SMTP id 28so7244186wyb.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 10:25:00 -0800 (PST)
In-Reply-To: <20101201.101809.71122121.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 10:18 -0800, David Miller a =C3=
=A9crit :
> From: Hagen Paul Pfeifer <hagen@jauu.net>
> Date: Wed, 01 Dec 2010 18:22:48 +0100
>=20
> > On Wed, 01 Dec 2010 09:42:47 +0100, Eric Dumazet wrote:
> >=20
> >> IMHO, a better pcap optimizer would be the first step.
> >=20
> > +1
> >=20
> > Optimizing complex filter rules is step one in the process of optim=
izing
> > the packet processing. A JIT compiler like FreeBSD provides cannot =
polish a
> > (pcap)turd. I thought Patrick was working on a generic filter mecha=
nism for
> > netfilter!? ... ;)
>=20
> Yes, and we spoke at the netfilter workshop about making that interpr=
eter
> available to socket filters and the packet classifier layer.
>=20
> However, I think it's still valuable to write a few JIT compilers for
> the existing BPF stuff.  I considered working on a sparc64 JIT just t=
o
> see what it would look like.
>=20
> If people work on the BPF optimizer and BPF JITs in parallel, we'll h=
ave
> both ready at the same time.  win++

A third work in progress (from my side) is to add a check in
sk_chk_filter() to remove the memvalid we added lately to protect the
LOAD M(K).

It is needed anyway for arches without a BPF JIT :)



