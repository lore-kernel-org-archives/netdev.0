From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/2] dsa: bug fixes
Date: Mon, 21 Jan 2013 20:58:49 +0100
Message-ID: <1358798331-13055-1-git-send-email-florian@openwrt.org>
Cc: buytenh@wantstofly.org, konszert@marvell.com, davem@davemloft.net,
	Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:43896 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756561Ab3AUUBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 15:01:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David, Lennert,

These two patches are non-critical bugfixes based on net-next which I
stumbled upon while working on Device Tree bindings for DSA (will comme
as a separate patch later).

Florian Fainelli (2):
  dsa: use an unique and non conflicting bus name for the slave MII bus
  dsa: make dsa_switch_setup check for valid port names

 net/dsa/dsa.c   |    6 ++++++
 net/dsa/slave.c |    4 ++--
 2 files changed, 8 insertions(+), 2 deletions(-)

-- 
1.7.10.4
