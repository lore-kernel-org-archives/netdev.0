From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Tue, 17 Feb 2009 14:51:56 -0800 (PST)
Message-ID: <20090217.145156.248068130.davem@davemloft.net>
References: <200902172001.41804.arvidjaar@mail.ru>
	<200902172117.22671.arvidjaar@mail.ru>
	<499B19AF.1000003@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvidjaar@mail.ru, rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37344
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752318AbZBQWwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 17:52:12 -0500
In-Reply-To: <499B19AF.1000003@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 17 Feb 2009 15:10:23 -0500

> Is it a common configuration to not allow a module to load like
> you're doing in modprobe.conf?  I don't know how hard it would be to
> rip this out into it's own bonding_ipv6.ko module, simply
> turning-off CONFIG_IPV6 seems better.

It's unfortunately how users get told to turn off ipv6.

There were some back-compat issues with how GLIBC emitted DNS requests
a few months ago that required turning off ipv6 completely otherwise
DNS requests would timeout.

Sticking an ipv6.ko module load disable into /etc/modprobe.conf
was the only tenable workaround.
