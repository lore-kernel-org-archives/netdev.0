From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] netns: IPv4 multicast routing per-namespace
Date: Thu, 22 Jan 2009 14:05:18 -0800 (PST)
Message-ID: <20090122.140518.206792271.davem@davemloft.net>
References: <20090122145614.925445566@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42785
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751336AbZAVWFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:05:16 -0500
In-Reply-To: <20090122145614.925445566@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Thu, 22 Jan 2009 15:56:14 +0100

> This patchset introduces the support for network namespaces in IPv4
> multicast routing code (net/ipv4/ipmr.c).
> 
> The structure of this patchset is similar to the "IPv6 multicast routing
> per namespace" patchset merged previously into 2.6.29.
> 
> The first patches in the series moves global data from ipmr.c into 
> struct netns_ipv4 to prepare netns support. Data are still referenced in
> init_net only. One of these patches makes the related /proc entries
> per-namespace.
> 
> The last patch does the main job and enables the network namespace support
> by replacing all the init_net references with the proper net retrieved
> from sockets or net devices.
> 
> The patchset applies on top of net-next-2.6

This all looks good, applied to net-next-2.6

Thanks!
