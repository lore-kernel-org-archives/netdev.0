From: David Lamparter <equinox@diac24.net>
Subject: [PATCH v3] ipv6: addrconf: fix mcast route for GRE devices
Date: Thu, 31 Jul 2014 22:53:52 +0200
Message-ID: <1406840034-140848-1-git-send-email-equinox@diac24.net>
References: <20140731201926.GA754314@jupiter.n2.diac24.net>
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:54564 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbaGaUy2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 16:54:28 -0400
In-Reply-To: <20140731201926.GA754314@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series replaces the previous patches in this thread, reposting them as
- patch 1/2: "ipv6: addrconf: fix mcast route for GRE devices"
which contains the semantic changes for the ff00::/8 route on GRE, and
- patch 2/2:  ipv6: addrconf: clean up device type handling"
which just moves things to make them prettier, and documents the "speshul"
fe80::/64 behaviour (which Nicolas Dichtel added in 08b4465 to make a specific
user case work.)

Tested by poking various devices with a bunch of link ups and downs.

Hannes, can you Ack?

-David
