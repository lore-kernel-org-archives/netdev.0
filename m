From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] netns: make IPv6 multicast forwarding
 per-namespace - V2
Date: Wed, 10 Dec 2008 16:31:06 -0800 (PST)
Message-ID: <20081210.163106.44703601.davem@davemloft.net>
References: <20081210160301.883947374@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	adobriyan@gmail.com, dlezcano@fr.ibm.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50988
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752657AbYLKAbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 19:31:07 -0500
In-Reply-To: <20081210160301.883947374@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Wed, 10 Dec 2008 17:03:01 +0100

> This patchset introduces the support for network namespaces in IPv6
> multicast forwarding code (net/ipv6/ip6mr.c).
> 
> The first patches in the series moves global data from ip6mr.c into 
> struct netns_ipv6 to prepare netns support. Data are still referenced in
> init_net only. One of these patches makes the related /proc entries
> per-namespace.
> 
> The last patch does the main job and enables the network namespace support
> by replacing all the init_net references with the proper net retrieved
> from sockets or net devices.
> 
> The patchset applies on top of net-next-2.6

Looks good, all applied, thanks Benjamin.
