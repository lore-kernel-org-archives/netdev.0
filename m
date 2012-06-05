From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [PATCH v3 net-next 0/5] gianfar: coding style cleanups
Date: Tue,  5 Jun 2012 15:42:10 +0200
Message-ID: <1338903735-24527-1-git-send-email-jan.ceuleers@computer.org>
Cc: Jiajun Wu <b06378@freescale.com>, Joe Perches <joe@perches.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:49456 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756215Ab2FENpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 09:45:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various coding style cleanups, mostly whitespace and comment reformatting.

I have left a number of lines untouched where I felt that the changes I
was considering were not improving readability. But de gustibus etc.

Patch 4/5 also removes some superfluous local variable initialisations.
These are obviously correct because the variable is initialised again
right after. But you might consider this to be unnecessary code churn
because the compiler is unlikely to generate better code due to this patch.

WARNING: Compile-tested only. I do not have the hardware.

This is my first patch _series_ submission; please be kind.

v3: no changes from v2, except now compile-tested using powerpc crosstool

v2: fixed typo in 5/5 (found by David)

Jan Ceuleers (5):
  gianfar: whitespace cleanup - pointers and multiplications
  gianfar: comment cleanup
  gianfar: various coding style and whitespace cleanups
  gianfar: Remove superfluous initialisations
  gianfar_ethtool: coding style and whitespace cleanups

 drivers/net/ethernet/freescale/gianfar.c         |  491 +++++++++++-----------
 drivers/net/ethernet/freescale/gianfar_ethtool.c |  420 +++++++++---------
 2 files changed, 479 insertions(+), 432 deletions(-)

-- 
1.7.9.5
