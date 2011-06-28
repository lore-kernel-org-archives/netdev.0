From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/core: Convert to current logging forms
Date: Tue, 28 Jun 2011 14:55:40 -0700
Message-ID: <1309298140.29598.31.camel@Joe-Laptop>
References: <385ebf7e98e377e6e6c384beb961b65d4a95fb18.1309289792.git.joe@perches.com>
	 <1309292501.2771.48.camel@bwh-desktop>
	 <1309293068.29598.14.camel@Joe-Laptop>
	 <1309293416.2771.50.camel@bwh-desktop>
	 <1309297068.29598.26.camel@Joe-Laptop>
	 <20110628144923.2bdac9f9@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3278 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783Ab1F1Vzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 17:55:43 -0400
In-Reply-To: <20110628144923.2bdac9f9@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-28 at 14:49 -0700, Stephen Hemminger wrote:
> Does this actually create useful benefit or just create more bug possibilities?

Probably not the bug possibilities.
It's pretty trivial.

> Those messages are mostly self explanatory as is.

It also has some utility for the cases in drivers
between the alloc_netdev and register_netdev[ice]
where printk/pr_<level> currently has to be used.

Beyond that, (foolish?) consistency only.

cheers, Joe

