From: David Miller <davem@davemloft.net>
Subject: Re: getsockopt(TCP_DEFER_ACCEPT) value change
Date: Tue, 05 Jan 2010 12:29:03 -0800 (PST)
Message-ID: <20100105.122903.241453878.davem@davemloft.net>
References: <4B4317AD.1040302@free.fr>
	<alpine.DEB.2.00.1001051526520.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: daniel.lezcano@free.fr, ja@ssi.bg, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53682
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754686Ab0AEU3B convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 15:29:01 -0500
In-Reply-To: <alpine.DEB.2.00.1001051526520.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 5 Jan 2010 15:40:57 +0200 (EET)

> In general, I wonder if there's something that mandates that a set/ge=
t=20
> pair of value should be equal?

There is no such requirement, we've been violating that premise since
day one for socket receive and send queue buffer limit socket options.

The kernel is always allowed to add fuzz or overhead adjustments to
whatever the user gives it.  If the user wants to know what the kernel
actually ended up using, it get getsockopt() to find out.
