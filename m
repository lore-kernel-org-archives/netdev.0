From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 14470] New: freez in TCP stack
Date: Wed, 02 Dec 2009 22:24:46 -0800 (PST)
Message-ID: <20091202.222446.10943991.davem@davemloft.net>
References: <4AE92F4D.6070101@gmail.com>
	<20091029.010009.175904855.davem@davemloft.net>
	<alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, akpm@linux-foundation.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kolo@albatani.cz, bugzilla-daemon@bugzilla.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48323
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751020AbZLCGYk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 01:24:40 -0500
In-Reply-To: <alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 26 Nov 2009 23:54:53 +0200 (EET)

> [PATCH] tcp: clear hints to avoid a stale one (nfs only affected?)

Ok, since Linus just released 2.6.32 I'm tossing this into net-next-2.6
so it gets wider exposure.

I still want to see test results from the bug reporter, and if it fixes
things we can toss this into -stable too.
