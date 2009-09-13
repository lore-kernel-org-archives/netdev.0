From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH] etherdevice.h: random_ether_addr update
Date: Sat, 12 Sep 2009 17:44:46 -0700
Message-ID: <1252802686.4400.19.camel@Joe-Laptop.home>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	 <20090910190703.25d14533@nehalam>
	 <1252638163.4355.35.camel@Joe-Laptop.home>
	 <20090911.121542.45333246.davem@davemloft.net>
	 <1252700442.15292.62.camel@Joe-Laptop.home>
	 <20090911141554.0072d365@nehalam>
	 <1252717067.29420.22.camel@Joe-Laptop.home>
	 <20090913094409.2dd88212@opy.nosense.org>
	 <20090913100342.4f6a2417@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, gregory.v.rose@intel.com,
	donald.c.skidmore@intel.com
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1127 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046AbZIMAop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Sep 2009 20:44:45 -0400
In-Reply-To: <20090913100342.4f6a2417@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-09-13 at 10:03 +0930, Mark Smith wrote:
> Hmm, probably didn't make my point all that clear. IOW, anything that
> can contribute to avoiding duplicate mac addresses is worth it in my
> opinion, when compared to the time (usually hours) involved in
> troubleshooting duplicate mac addresses.

Avoiding an initial octet of "02", which is partially
assigned to 3Com and others, might be useful.

Not drawing from entropy I think useful, but it's debatable.


