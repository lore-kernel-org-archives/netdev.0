From: David Miller <davem@davemloft.net>
Subject: Re: [STABLE][3.0][3.2][Add PATCH] phy/fixed: use an unique MDIO
 bus name
Date: Sun, 07 Oct 2012 14:56:22 -0400 (EDT)
Message-ID: <20121007.145622.83624305358947187.davem@davemloft.net>
References: <1349441987.6755.45.camel@gandalf.local.home>
	<1349624019.16173.113.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, gregkh@linuxfoundation.org,
	florian@openwrt.org, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061Ab2JGS4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 14:56:24 -0400
In-Reply-To: <1349624019.16173.113.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 07 Oct 2012 16:33:39 +0100

> Networking stable fixes are normally vetted, backported and bundled up
> by David, so I'll let him decide on this.
> 
> There are a lot more MDIO bus drivers that don't play nicely with
> others, most of which seem to be fixed in mainline.  If David agrees
> that these are generally worthwhile then perhaps someone could try to
> gather those up?

I very much am not inclined to backport this stuff, it impacts
an extremely small group of people so the risk/benefit ratio is
simply not worth it for me to do the work.

If someone else does the work and tests it, I'm willing to ACK
it going into -stable.

But this change impacted a lot of MDIO drivers and there were
regressions that needed to be fixed up the first time this stuff
went in.
