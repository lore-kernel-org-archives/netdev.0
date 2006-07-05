From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: 2.6.17-mm6
Date: Wed, 05 Jul 2006 12:36:35 +0200
Message-ID: <44AB9633.9090208@s5r6.in-berlin.de>
References: <20060703030355.420c7155.akpm@osdl.org>	 <200607042153.31848.rjw@sisk.pl> <1152043271.3109.95.camel@laptopd505.fenrus.org> <44AB940F.7000801@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.TU-Cottbus.De ([141.43.120.68]:20918 "EHLO
	hp3.statik.tu-cottbus.de") by vger.kernel.org with ESMTP
	id S964807AbWGEKj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 06:39:27 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <44AB940F.7000801@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I wrote:
> (Ieee1394 core's usage of the skb_* API is entirely unrelated to
> networking; even if eth1394 was used.)

PS:
I wonder if it wouldn't be better to migrate ieee1394 core away from
skb_*. I didn't look thoroughly at it yet but the benefit of using this
API appears quite low to me.

We use it to keep track of IEEE 1394 transactions [ = outgoing request
&& (incoming response || expiry)], with completion of transactions often
in-order due to mostly single-threaded usage, but sometimes out-of-order
(may happen regardless of multithreaded or single-threaded usage).
-- 
Stefan Richter
-=====-=-==- -=== --=-=
http://arcgraph.de/sr/
