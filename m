From: Florian Westphal <fw@strlen.de>
Subject: Re: ipv6: Add support for RTA_PREFSRC
Date: Thu, 7 Apr 2011 23:25:52 +0200
Message-ID: <20110407212552.GA11115@Chamillionaire.breakpoint.cc>
References: <20110401.204613.246536923.davem@davemloft.net>
 <1301903804.31789.234.camel@localhost>
 <20110406.183716.226766155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dwalter@barracuda.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:37088 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751578Ab1DGVZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 17:25:55 -0400
Content-Disposition: inline
In-Reply-To: <20110406.183716.226766155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Daniel Walter <dwalter@barracuda.com>
> Date: Mon, 4 Apr 2011 09:56:44 +0200
> > This reduces the RTA_PREFSRC support to netlink only, unless
> > we break the struct.
> 
[..]
> Since you do the prefsrc extraction in at least two places, make a
> helper function that does the whole "if prefsrc.plen use prefsrc, else
> use ipv6_dev_get_saddr()"
> 
> This would be akin to ipv4's FIB_RES_PREFSRC

OK, I'll bite.

Whats wrong with using ipv6 addrlabels to pick the desired address,
and, if there is a problem, why is it not fixable?

Just wondering...
