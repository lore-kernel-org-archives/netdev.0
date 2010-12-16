From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
 packets
Date: Thu, 16 Dec 2010 23:42:37 +0100
Message-ID: <20101216224237.GC2191@del.dom.local>
References: <1292428252.3427.342.camel@edumazet-laptop>
 <20101216211744.GA2191@del.dom.local>
 <1292535039.2655.13.camel@edumazet-laptop>
 <20101216220838.GB2191@del.dom.local>
 <1292538363.2655.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51972 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab0LPWmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:42:43 -0500
Received: by wwa36 with SMTP id 36so67669wwa.1
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 14:42:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292538363.2655.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 11:26:03PM +0100, Eric Dumazet wrote:
> Le jeudi 16 d=E9cembre 2010 ?? 23:08 +0100, Jarek Poplawski a =E9crit=
 :
>=20
> > Hmm... Do you expect more people start debugging SFQ or I missed yo=
ur
> > point? ;-) Maybe such a change would be reasonable on a cloned skb?
>=20
> My point was to permit an admin to check his ingress shaping works or
> not. In this respect, netem was a specialization of a general problem=
=2E
>=20
> We had a prior discussion on timestamping skb in RX path, when RPS ca=
me
> in : Should we take timestamp before RPS or after. At that time we ad=
ded
> a sysctl. Not sure it was the right choice :-(
>=20
> I feel tcpdump (on TX side) should really display time of packet righ=
t
> before being given to device, but this is probably a matter of taste.

It might be reasonable unless it changes data for later users. That's
why I mentioned cloning.

>=20
> Before commit 8caf153974f2 (net: sch_netem: Fix an inconsistency in
> ingress netem timestamps.), this is what was done.

Then why don't you try to let turn it off in netem, where it only
matters?

Jarek P.
