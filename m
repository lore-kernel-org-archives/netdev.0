From: Marco Berizzi <pupilla@hotmail.com>
Subject: RE: kernel ipsec error
Date: Tue, 12 Jun 2012 08:31:18 +0200
Message-ID: <DUB108-W54AAF31BD3E442DF275349B2F60@phx.gbl>
References: <DUB108-W3906ACEA67D9618490CB02B2F70@phx.gbl>,<1339436963.2665.5.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc1-s15.dub0.hotmail.com ([157.55.0.214]:53301 "EHLO
	dub0-omc1-s15.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751670Ab2FLGbU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2012 02:31:20 -0400
In-Reply-To: <1339436963.2665.5.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


bhutchings@solarflare.com wrote:
> On Mon, 2012-06-11 at 14:45 +0200, Marco Berizzi wrote:
> > Hello everybody.
> >
> > After 12 days uptime I got this message.
> > Linux is 3.3.5 32bit, running openswan
> > (this is an ipsec gateway/netfilter
> > firewall) and squid.
> >
> > Jun 11 12:53:02 Pleiadi kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x20)
> > Jun 11 12:53:02 Pleiadi kernel: cache: kmalloc-2048, object size: 2048, buffer size: 2048, default order: 2, min order: 0
> > Jun 11 12:53:02 Pleiadi kernel: node 0: slabs: 61, objs: 476, free: 0
> > Jun 11 12:53:02 Pleiadi kernel: kworker/0:2: page allocation failure: order:0, mode:0x4020
>
> So a single page allocation in atomic (non-sleeping) context failed.
>
> [...]
> > Jun 11 12:53:02 Pleiadi kernel: Free swap = 130908kB
> > Jun 11 12:53:02 Pleiadi kernel: Total swap = 151164kB
> > Jun 11 12:53:02 Pleiadi kernel: 40944 pages RAM
> [...]
>
> Not too surprising with this little RAM available (swap didn't help
> since we couldn't wait for swap-out).

yes, this is really a very old hardware.

> There could be a memory leak, but you would need to read /proc/meminfo
> and /proc/slabinfo at intervals to work out whether that was the case.

Kindly, may you tell me which should be the intervals? One second? one minute?
 		 	   		  