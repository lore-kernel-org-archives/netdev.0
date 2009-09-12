From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH] etherdevice.h: random_ether_addr update
Date: Fri, 11 Sep 2009 17:57:47 -0700
Message-ID: <1252717067.29420.22.camel@Joe-Laptop.home>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	 <20090910190703.25d14533@nehalam>
	 <1252638163.4355.35.camel@Joe-Laptop.home>
	 <20090911.121542.45333246.davem@davemloft.net>
	 <1252700442.15292.62.camel@Joe-Laptop.home>
	 <20090911141554.0072d365@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com,
	donald.c.skidmore@intel.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1121 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbZILA5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 20:57:45 -0400
In-Reply-To: <20090911141554.0072d365@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-09-11 at 14:15 -0700, Stephen Hemminger wrote:
> On Fri, 2009-09011 at 13:20 -0700 Joe Perches wrote:
> > Do not use get_random_bytes to avoid drawing down entropy pool.
> Getting 6 bytes once is not going to be enough of a problem
> to drain the pool. I prefer not to weaken the randomness here.

I see no reason to draw down the entropy pool.

I have a hard time imagining that a random mac address
needs more than reasonably random values.

Why do you think it's reasonable to draw from the
entropy pool?

cheers, Joe

