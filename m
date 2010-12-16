From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: force a fresh timestamp for ingress
 packets
Date: Thu, 16 Dec 2010 23:26:03 +0100
Message-ID: <1292538363.2655.20.camel@edumazet-laptop>
References: <1292428252.3427.342.camel@edumazet-laptop>
	 <20101216211744.GA2191@del.dom.local>
	 <1292535039.2655.13.camel@edumazet-laptop>
	 <20101216220838.GB2191@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60470 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab0LPW0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:26:08 -0500
Received: by wyb28 with SMTP id 28so45411wyb.19
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 14:26:06 -0800 (PST)
In-Reply-To: <20101216220838.GB2191@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 23:08 +0100, Jarek Poplawski a =C3=
=A9crit :

> Hmm... Do you expect more people start debugging SFQ or I missed your
> point? ;-) Maybe such a change would be reasonable on a cloned skb?

My point was to permit an admin to check his ingress shaping works or
not. In this respect, netem was a specialization of a general problem.

We had a prior discussion on timestamping skb in RX path, when RPS came
in : Should we take timestamp before RPS or after. At that time we adde=
d
a sysctl. Not sure it was the right choice :-(

I feel tcpdump (on TX side) should really display time of packet right
before being given to device, but this is probably a matter of taste.

Before commit 8caf153974f2 (net: sch_netem: Fix an inconsistency in
ingress netem timestamps.), this is what was done.



