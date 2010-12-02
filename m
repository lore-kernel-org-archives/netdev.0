From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] filter: add a security check at install
 time
Date: Thu, 02 Dec 2010 12:15:48 +0100
Message-ID: <1291288548.2871.51.camel@edumazet-laptop>
References: <1291227893.2856.1039.camel@edumazet-laptop>
	 <20101201.104450.183053379.davem@davemloft.net>
	 <1291232937.2856.1042.camel@edumazet-laptop>
	 <20101201.122312.229751364.davem@davemloft.net>
	 <1291236342.2856.1057.camel@edumazet-laptop>
	 <AANLkTikK=dy6U0QBjkJxZXeqYXVHwZqjmRhnmYBH-22r@mail.gmail.com>
	 <1291272384.2856.1074.camel@edumazet-laptop>
	 <AANLkTim8+9AA61HwcCQp3p7cSjzaTqerdd4Wtm-28kAt@mail.gmail.com>
	 <1291280000.2871.16.camel@edumazet-laptop>
	 <1291280402.2871.20.camel@edumazet-laptop>
	 <AANLkTikQOY7Nh7XOFT9wXDYpn1faVS9xH2Y-x67hiu7S@mail.gmail.com>
	 <1291283693.2871.48.camel@edumazet-laptop>
	 <AANLkTikkeQNzTMs_AifJFFU3oEKAmMBaCO9PCRWLRTSo@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	wirelesser@gmail.com, netdev@vger.kernel.org,
	Dan Rosenberg <drosenberg@vsecurity.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36017 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab0LBLP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 06:15:59 -0500
Received: by wwa36 with SMTP id 36so8588734wwa.1
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 03:15:58 -0800 (PST)
In-Reply-To: <AANLkTikkeQNzTMs_AifJFFU3oEKAmMBaCO9PCRWLRTSo@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 d=C3=A9cembre 2010 =C3=A0 18:10 +0800, Changli Gao a =C3=A9=
crit :

> > (By the way, I believe FreeBSD has the security problem Dan reporte=
d to us)
>=20
> Yes. it doesn't do this check.
>=20

Their scratch memory is not on stack but part of the filter, so no
security problem (You can only read previous values of scratch register=
s
written by your own filter on handling a previous packet.)

This means it is either run on a single CPU, or there is a hidden SMP
bug in their implementation.



