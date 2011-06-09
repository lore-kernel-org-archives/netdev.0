From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/9] 64 bit statistics for VM and 10G drivers
Date: Wed, 08 Jun 2011 17:53:56 -0700
Message-ID: <20110609005356.160260858@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752262Ab1FIBQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All 10G and virtual devices should be using the 64 bit statistics interface
because counters can wrap to fast. The standard monitoring program net-snmp
polls devices every 3 seconds (too fast), but even that can wrap too fast
to be detected.

Net-snmp needs to be updated to use netlink and handle 64 bit values.
It is still using /proc


