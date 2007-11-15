From: Patrick McHardy <kaber@trash.net>
Subject: [MACVLAN 00/02]: Macvlan update
Date: Thu, 15 Nov 2007 16:54:29 +0100 (MET)
Message-ID: <20071115155427.12874.34461.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48710 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757249AbXKOPya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 10:54:30 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These two patches remove an unnecessary check in macvlan_broadcast() and
add the ability to change the mac address while the device is up.

Please apply, thanks.


 drivers/net/macvlan.c |   26 ++++++++++++++++++++++++--
 1 files changed, 24 insertions(+), 2 deletions(-)

Patrick McHardy (2):
      [MACVLAN]: Remove unnecessary IFF_UP check
      [MACVLAN]: Allow setting mac address while device is up
