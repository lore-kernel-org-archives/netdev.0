From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 09:42:47 +0100
Message-ID: <1291192967.2856.492.camel@edumazet-laptop>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
	 <1291109699.2904.11.camel@edumazet-laptop>
	 <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
	 <1291127670.2904.96.camel@edumazet-laptop>
	 <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
	 <AANLkTimynbhgo2dqFwKOc8NT9TXpkCtCJMvwkySEBORz@mail.gmail.com>
	 <1291189649.2856.478.camel@edumazet-laptop>
	 <AANLkTinQ9c_C6LzNf5c3BbJXQTVKmbqf6KR9K23tGETw@mail.gmail.com>
	 <1291190956.2856.485.camel@edumazet-laptop>
	 <AANLkTin6d=t6U28A-r=FznqE+5QuGXwg1tStOw-JXabg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rui <wirelesser@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62742 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839Ab0LAImx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 03:42:53 -0500
Received: by wyb28 with SMTP id 28so6676658wyb.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 00:42:52 -0800 (PST)
In-Reply-To: <AANLkTin6d=t6U28A-r=FznqE+5QuGXwg1tStOw-JXabg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 16:15 +0800, Changli Gao a =C3=
=A9crit :
> On Wed, Dec 1, 2010 at 4:09 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> >
> > A dream would be to have a native compiler, and not interpret pseud=
o
> > code...
> >
>=20
> FYI: FreeBSD's BPF implementation have JIT compilers in kernel on bot=
h
> i386 and amd64.
>=20


IMHO, a better pcap optimizer would be the first step.

If you take a look at their generated code, its not a real win over the
code we currently have.


Really.



