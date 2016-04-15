From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH net-next 0/2] Minor IFF_NO_QUEUE conversion follow-up
Date: Fri, 15 Apr 2016 19:14:18 +0200
Message-ID: <1460740460-12859-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36905 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014AbcDOROe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2016 13:14:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series converts two further drivers away from setting
'tx_queue_len = 0' to adding IFF_NO_QUEUE to priv_flags instead.

The first one, rtl8188eu in staging didn't exist back when all drivers
were converted. The second one, openvswitch seems to have slipped through
my grep'ing back then, no idea why.

Phil Sutter (2):
  staging: rtl8188eu: Convert to using IFF_NO_QUEUE
  openvswitch: Convert to using IFF_NO_QUEUE

 drivers/staging/rtl8188eu/os_dep/mon.c | 2 +-
 net/openvswitch/vport-internal_dev.c   | 3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

-- 
2.8.0
