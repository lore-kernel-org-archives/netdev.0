From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 0/8] netns: make IPv6 multicast forwarding per-namespace
Date: Mon, 08 Dec 2008 17:01:56 +0100
Message-ID: <20081208160156.343758157@localhost.localdomain>
Cc: netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:34800 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbYLHQC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 11:02:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset introduces the support for network namespaces in IPv6
multicast forwarding code (net/ipv6/ip6mr.c).

The first patches in the series moves global data from ip6mr.c into 
struct netns_ipv6 to prepare netns support. Data are still referenced in
init_net only. One of these patches makes the related /proc entries
per-namespace.

The last patch does the main job and enables the network namespace support
by replacing all the init_net references with the proper net retrieved
from sockets or net devices.

The patchset applies on top of net-next-2.6

Regards,
Benjamin

