From: Theodore Tso <tytso@mit.edu>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Wed, 18 Feb 2009 08:55:37 -0500
Message-ID: <20090218135537.GF3600@mini-me.lan>
References: <200902172001.41804.arvidjaar@mail.ru> <20090217.142946.232071526.davem@davemloft.net> <25143.1234932076@turing-police.cc.vt.edu> <20090217.212919.259912220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Valdis.Kletnieks@vt.edu, arvidjaar@mail.ru, rjw@sisk.pl,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	jamagallon@ono.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from THUNK.ORG ([69.25.196.29]:57530 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011AbZBROBh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 09:01:37 -0500
Content-Disposition: inline
In-Reply-To: <20090217.212919.259912220.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 17, 2009 at 09:29:19PM -0800, David Miller wrote:
> Next, if it's just an issue of IPV6 traffic, install a packet
> scheduler rule that rejects all packets with ethernet proto
> ETH_P_IPV6
> 
> If openning up ipv6 sockets is problematic, that can be blocked
> using the security layer, which your super-duper distro kernel
> is guarenteed to have enabled. :-)
> 
> I'm sure there is someone who has legacy problems with ipv4
> and that can't be disabled, and somehow people cope.  Amazing.

The reality is that there are far more people who have legacy problems
with ipv6 than ipv4 (which has been around and in active use for about
3 decades, after all), whereas ipv6 has been around and largely
ignored for about a decade.  :-/

I'll admit that I ran into some wierd sh*t problems with some open
source software or another failing mysteriously when IPv6 was enabled,
and I dealt with it by simply disabling IPv6 (yeah, I blocked the
module).  I was in a hurry, and it just didn't work, and I had better
thing to do than to spend time trying to debug why the presense of an
IPv6 enabled interface caused programs to misbehave in random ways.

I think I can pretty much guarantee that distro users will be
clamoring for a quick and easy way to block ipv6, and it's in our
interest to document the recomended way to block it that doesn't cause
weird problems with bonding, etc.

						- Ted
