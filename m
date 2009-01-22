From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 0/9] netns: IPv4 multicast routing per-namespace
Date: Thu, 22 Jan 2009 15:56:14 +0100
Message-ID: <20090122145614.925445566@theryb.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58325 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbZAVO5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 09:57:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset introduces the support for network namespaces in IPv4
multicast routing code (net/ipv4/ipmr.c).

The structure of this patchset is similar to the "IPv6 multicast routing
per namespace" patchset merged previously into 2.6.29.

The first patches in the series moves global data from ipmr.c into 
struct netns_ipv4 to prepare netns support. Data are still referenced in
init_net only. One of these patches makes the related /proc entries
per-namespace.

The last patch does the main job and enables the network namespace support
by replacing all the init_net references with the proper net retrieved
from sockets or net devices.

The patchset applies on top of net-next-2.6

Regards,
Benjamin

