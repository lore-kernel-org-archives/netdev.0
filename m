From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: [RFC v2 net-next 0/5] gianfar: coding style cleanups
Date: Tue,  5 Jun 2012 09:07:11 +0200
Message-ID: <1338880036-11533-1-git-send-email-jan.ceuleers@computer.org>
Cc: Jiajun Wu <b06378@freescale.com>, Joe Perches <joe@perches.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:49550 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751254Ab2FEHJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 03:09:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various coding style cleanups, mostly whitespace and comment reformatting.

I have left a number of lines untouched where I felt that the changes I
was considering were not improving readability. But de gustibus etc.

Patch 4/5 also removes some superfluous local variable initialisations.
These are obviously correct because the variable is initialised again
right after. But you might consider this to be unnecessary code churn
because the compiler is unlikely to generate better code due to this patch.

WARNING: ENTIRELY UNTESTED. Not even compile-tested. Sorry but I haven't
figured out how to cross-compile (I tried). Would the Freescale team please
pick this series up?

This is my first patch _series_ submission; please be kind.

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
