From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] ipv6: Prevent access to uninitialized fib_table_hash via
 /proc/net/ipv6_route
Date: Tue, 19 Jun 2012 07:36:02 -0400
Message-ID: <20120619113602.GG27921@canuck.infradead.org>
References: <e4b53a15fadbe5c1aa5402fcc8172b0ee281da33.1339750783.git.tgraf@suug.ch>
 <20120615105655.GA22945@hmsreliant.think-freely.org>
 <20120615.153240.1699971156820399680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:32827 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532Ab2FSLgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 07:36:07 -0400
Content-Disposition: inline
In-Reply-To: <20120615.153240.1699971156820399680.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 15, 2012 at 03:32:40PM -0700, David Miller wrote:
> Since you're snooping around in here, you might notice that on network
> namespace shutdown, we leak all user configured ipv6 FIB rules.

I looked into this. fib_rules_unregister() will free all rules
belonging to the address family in that namespace.

Or were you referring to other rules?
