From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: addrconf: fix mcast route for GRE devices
Date: Thu, 31 Jul 2014 12:06:52 -0700 (PDT)
Message-ID: <20140731.120652.225147288366144806.davem@davemloft.net>
References: <20140730153503.GJ801478@jupiter.n2.diac24.net>
	<1406734797-122248-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	stephen@networkplumber.org
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbaGaTGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 15:06:53 -0400
In-Reply-To: <1406734797-122248-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Wed, 30 Jul 2014 17:39:57 +0200

> GRE devices, for some reason, were coming up with an autoconfigured
> address, but no ff00::/8 route in the local table.  This breaks any kind
> of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
> works at all because there is little need for ND on PtP devices.
> 
> Adding any other IPv6 address on the device from userspace would rectify
> this issue through inet6_addr_add()/addrconf_add_dev() - and would leave
> the route around even if the address was later removed.  (This is
> probably why this issue was not discovered earlier.  AFAICS it has been
> there from the beginning, e.g. aee80b5 "generate link local address for
> GRE tunnel")
> 
> (Note: multicast is supported on GRE devices of all kinds, including PtP
> GRE, P-t-Mcast GRE and NBMA-GRE.)
> 
> Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
> Signed-off-by: David Lamparter <equinox@diac24.net>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>

Hannes, are you OK with this version?  Please ACK if so.

Thanks.
