From: Pascal Hambourg <pascal.mail@plouf.fr.eu.org>
Subject: Re: Routing over multiple interfaces
Date: Tue, 02 Nov 2010 20:46:44 +0100
Message-ID: <4CD06AA4.6090005@plouf.fr.eu.org>
References: <1288645922.5977.41.camel@macbook.infradead.org>	 <20101101.141638.116372747.davem@davemloft.net> <1288647330.2660.116.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dwmw2@infradead.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poutre.nerim.net ([62.4.16.124]:65011 "EHLO poutre.nerim.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755178Ab0KBTqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Nov 2010 15:46:48 -0400
In-Reply-To: <1288647330.2660.116.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Eric Dumazet a =E9crit :
>=20
> David W. probably wants to use teql or some bonding ?

I doubt that (ethernet) bonding works with PPP links.

> # tc qdisc add dev ppp0 root teql0
> # tc qdisc add dev ppp1 root teql0
> # ip link set dev teql0 up
> # ip route add default src 90.155.92.214 dev teql0

What about using iptables + routing rules ?
Mark every other packet going through the default PPP link with
iptables, and reroute marked packets through the other PPP link.
