From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Tue, 17 Feb 2009 21:29:19 -0800 (PST)
Message-ID: <20090217.212919.259912220.davem@davemloft.net>
References: <200902172001.41804.arvidjaar@mail.ru>
	<20090217.142946.232071526.davem@davemloft.net>
	<25143.1234932076@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvidjaar@mail.ru, rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43445
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750891AbZBRF3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 00:29:35 -0500
In-Reply-To: <25143.1234932076@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valdis.Kletnieks@vt.edu
Date: Tue, 17 Feb 2009 23:41:16 -0500

> What does a poor corporate user do if they're running a distro kernel that
> was built with CONFIG_IPV6, but local security policy says "Disable IPv6
> because we don't do it yet, or because it breaks mission-critical software
> package XYZ?"  There's a *lot* of people who implement that by the "block
> the ipv6 module from loading" trick.  And building a kernel that doesn't
> include IPv6 may not be feasible due to vendor certification issues...
> 
> Heck, *I*'m almost in that boat - probably need to use bonded ethernet on some
> servers because we can't get 10GigE, but the software used in the project the
> servers were bought for blows chunks if it gets a whiff of an IPv6 address.
> Ended up spending 3 weeks doing a massive kludgery of one sort in DNS for the
> rest of the world, and equally massive lying in /etc/hosts for the hosts...
> (Don't ask - it was long and ugly, and just disabling the module would have
> saved me about 2.95 weeks of work, so I know where those people are coming
> from...)

Well, first of all, if you keep trying to push the box into the round
hole you get what you ask for :-)

Next, if it's just an issue of IPV6 traffic, install a packet
scheduler rule that rejects all packets with ethernet proto
ETH_P_IPV6

If openning up ipv6 sockets is problematic, that can be blocked
using the security layer, which your super-duper distro kernel
is guarenteed to have enabled. :-)

I'm sure there is someone who has legacy problems with ipv4
and that can't be disabled, and somehow people cope.  Amazing.
