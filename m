From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] IPv6: optionaly validate RAs on raw sockets
Date: Wed, 11 Jul 2007 19:19:11 +0300
Message-ID: <200707111919.11746@auguste.remlab.net>
References: <OF12E7973A.D9D0F9C5-ON88257315.005882D0-88257315.0058D5B9@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, davem@davemloft.net,
	netdev@vger.kernel.org,
	YOSHIFUJI Hideaki /
	 =?utf-8?q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:1541 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754818AbXGKQTQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 12:19:16 -0400
In-Reply-To: <OF12E7973A.D9D0F9C5-ON88257315.005882D0-88257315.0058D5B9@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 11 juillet 2007, David Stevens a =E9crit :
>         That sounds like a good idea to me (FWIW),
> though I also still think a simple raw-socket
> application would do it just fine, possibly with
> no kernel modification at all.
>         But since the kernel wouldn't be maintaining
> the DNS info, which was my real objection to the
> original version,  netlink would work well too.

One remaining corner case is NFS/IPv6 root, whereby userland won't have=
=20
a chance to start before the network, and hence may miss the solicited=20
RA. Or would it? By default, the next unsolicited RA can be anytime=20
from now to after 10 minutes, so that's not sufficient. I wouldn't=20
personnaly care, but...

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
