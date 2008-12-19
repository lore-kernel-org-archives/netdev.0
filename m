From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Stop scaring users with "treason uncloaked!"
Date: Thu, 18 Dec 2008 16:15:13 -0800 (PST)
Message-ID: <20081218.161513.241236470.davem@davemloft.net>
References: <1229638581.3726.546.camel@calx>
	<Pine.LNX.4.64.0812190028560.12061@wrl-59.cs.helsinki.fi>
	<1229644234.3726.577.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40595
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751412AbYLSAPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 19:15:11 -0500
In-Reply-To: <1229644234.3726.577.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Mackall <mpm@selenic.com>
Date: Thu, 18 Dec 2008 17:50:34 -0600

> If you want, we can instead say "Peer %d unexpectedly shrunk window...".
> So long as the scary bit is gone, I don't care.

Since we have established that the blame is equally possible to
be the local as the remote system, something like:

	TCP: Unexpected shrink of advertised window detected ...

is probably the best.
