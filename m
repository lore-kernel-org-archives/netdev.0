From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 02:51:59 -0700 (PDT)
Message-ID: <20081031.025159.51432990.davem@davemloft.net>
References: <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi>
	<20081031.005219.141937694.davem@davemloft.net>
	<Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, zbr@ioremap.net, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	efault@gmx.de, akpm@linux-foundation.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751035AbYJaJwY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 05:52:24 -0400
In-Reply-To: <Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 31 Oct 2008 11:40:16 +0200 (EET)

> Let me remind that it is just a single process, so no ping-pong & oth=
er=20
> lock related cache effects should play any significant role here, no?=
 (I'm=20
> no expert though :-)).

Not locks or ping-pongs perhaps, I guess.  So it just sends and
receives over a socket, implementing both ends of the communication
in the same process?

If hash chain conflicts do happen for those 2 sockets, just traversing
the chain 2 entries deep could show up.
