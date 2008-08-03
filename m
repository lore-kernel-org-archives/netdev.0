From: Sven Wegener <sven.wegener@stealer.net>
Subject: Re: oops in rt_cache_invalidate (2.6.27-rc1-2b12a4c)
Date: Sun, 3 Aug 2008 21:48:21 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0808032145550.29048@titan.stealer.net>
References: <20080803170241.GD5414@joi> <1217789775.8154.34.camel@iris.sw.ru> <alpine.LNX.1.10.0808032110520.7765@titan.stealer.net> <alpine.LNX.1.10.0808032141010.29048@titan.stealer.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Marcin Slusarz <marcin.slusarz@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.stealer.net ([88.198.224.204]:58267 "EHLO
	smtp1.stealer.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbYHCTsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 15:48:51 -0400
In-Reply-To: <alpine.LNX.1.10.0808032141010.29048@titan.stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 3 Aug 2008, Sven Wegener wrote:

> On Sun, 3 Aug 2008, Sven Wegener wrote:
> 
> > On Sun, 3 Aug 2008, Denis V. Lunev wrote:
> > 
> > > On Sun, 2008-08-03 at 19:02 +0200, Marcin Slusarz wrote:
> > > > [...]
> > > > It's 2b12a4c524812fb3f6ee590a02e65b95c8c32229 + some unreleated trivial patches.
> > > 
> > > Could you send you .config?
> > 
> > No need to, the issue can be triggered by
> > 
> > sysctl net.ipv4.ip_default_ttl=1
> > 
> > when 76e6ebfb40a2455c18234dcb0f9df37533215461 is applied.
> 
> Actually it's 86c657f6b5bbf2f3ec2213eca528998134a9b344, 76e6ebf adds the 
> initial code that accesses the extra2 parameter, but 86c657f adds the 
> oops.

I should stop for today, it's e84f84f276473dcc673f360e8ff3203148bdf0e2 
that has the &net->ipv4.rt_genid in rt_cache_invalidate(). ...
