From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/3] enic: add Makefile, patch Kconfg, MAINTAINERS, etc
Date: Mon, 25 Aug 2008 15:36:21 -0700
Message-ID: <adaiqtolo2i.fsf@cisco.com>
References: <Pine.LNX.4.64.0808251121150.3972@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:43604 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679AbYHYWga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:36:30 -0400
In-Reply-To: <Pine.LNX.4.64.0808251121150.3972@palito_client100.nuovasystems.com>
	(Scott Feldman's message of "Mon, 25 Aug 2008 11:26:41 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oh yeah, by the way, this patch got whitespace mangled somehow so it
won't apply (and also it seems to be against an old tree that doesn't
have the atl1e driver merged).

And:

 > +config ENIC
 > +	tristate "Cisco 10Gigabit Ethernet NIC"

The Kconfig file seems to use "10 Gigabit Ethernet" (with a space) or
variations on "10Gb Ethernet".  Probably worth it not to add yet another
variation.

 > +	depends on PCI
 > +	select INET_LRO

I believe if you select INET_LRO, you'd better depend on INET or else it
is possible to create unbuildable configs.
