From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 09:09:16 +0100
Message-ID: <1291190956.2856.485.camel@edumazet-laptop>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
	 <1291109699.2904.11.camel@edumazet-laptop>
	 <AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
	 <1291127670.2904.96.camel@edumazet-laptop>
	 <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
	 <AANLkTimynbhgo2dqFwKOc8NT9TXpkCtCJMvwkySEBORz@mail.gmail.com>
	 <1291189649.2856.478.camel@edumazet-laptop>
	 <AANLkTinQ9c_C6LzNf5c3BbJXQTVKmbqf6KR9K23tGETw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rui <wirelesser@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40586 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853Ab0LAIJV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 03:09:21 -0500
Received: by wwa36 with SMTP id 36so7076193wwa.1
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 00:09:20 -0800 (PST)
In-Reply-To: <AANLkTinQ9c_C6LzNf5c3BbJXQTVKmbqf6KR9K23tGETw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 15:59 +0800, Changli Gao a =C3=
=A9crit :
> On Wed, Dec 1, 2010 at 3:47 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> > Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 15:36 +0800, Changli Gao a=
 =C3=A9crit :
> >
> > Oh well, it seems you read over my neck, I was preparing a patch wi=
th
> > SKF_AD_RXHASH and SKF_AD_CPU
> >
> >
>=20
> Nice to hear it. :)
>=20
> There are too many filters: bpf, iptables and tc. Maybe an unified on=
e
> such as nft is needed. Then the duplicate code would be reduced. Mayb=
e
> it is just a good dream.
>=20

You forgot the rxhash function as well, it would be nice to augment it
with custom code if necessary.

A dream would be to have a native compiler, and not interpret pseudo
code...



