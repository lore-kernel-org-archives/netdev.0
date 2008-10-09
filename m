From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Thu, 9 Oct 2008 19:21:03 +0300
Message-ID: <200810091921.04230.rdenis@simphalempin.com>
References: <20081008081109.GA25342@1wt.eu> <20081008135402.7b837992@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47726 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753664AbYJIQVI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 12:21:08 -0400
In-Reply-To: <20081008135402.7b837992@speedy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 8 octobre 2008 14:54:02 Stephen Hemminger, vous avez =E9cri=
t=A0:
> Does this break NAT traversal via STUNT used by applications like Sky=
pe?

This will break the main ICE-TCP mechanism (IETF draft-ietf-mmusic-ice-=
tcp).
I am not aware of any application using this _as_of_now_. Probably too =
many=20
NAT and firewall implementations will reject it already. And then, some=
 TCP=20
stacks reportedly do not support it (e.g. Windows before Vista).

On the other hand, if someone were to tunnel/encapsulate TCP over UDP, =
this=20
could actually be useful - think about peer-to-peer NATted-to-NATted fi=
le=20
transfers for instance.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
