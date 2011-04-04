From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen: netfront: fix declaration order
Date: Sun, 03 Apr 2011 17:24:07 -0700 (PDT)
Message-ID: <20110403.172407.91341067.davem@davemloft.net>
References: <20110331110136.03A1A13A6A@rere.qmqm.pl>
	<20110401.205455.70198735.davem@davemloft.net>
	<1301828839.2837.143.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org,
	jeremy.fitzhardinge@citrix.com, konrad.wilk@oracle.com,
	Ian.Campbell@citrix.com, xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48295
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752031Ab1DDAYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 20:24:45 -0400
In-Reply-To: <1301828839.2837.143.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 03 Apr 2011 13:07:19 +0200

> [PATCH] xen: netfront: fix declaration order
>=20
> Must declare xennet_fix_features() and xennet_set_features() before
> using them.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>

Ugh, it makes no sense that XEN won't make it into the x86_32
allmodconfig build.  Those dependencies in arch/x86/xen/Kconfig
are terrible.

=46or if it did, I would have caught this immediately.
