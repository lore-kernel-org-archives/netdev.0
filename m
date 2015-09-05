From: romieu@fr.zoreil.com
Subject: [PATCH net 0/3] r8169: fix sleepable allocation during netdevice stats retrieval.
Date: Sat,  5 Sep 2015 14:18:51 +0200
Message-ID: <cover.1441454454.git.romieu@fr.zoreil.com>
Cc: David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	pomidorabelisima@gmail.com, vinschen@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57772 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbbIEMTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 08:19:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

This series applies against davem's net as of
724a7636ad026a3a68f3fc626ccd04111f65cfd9 ("Merge branch 'sctp-fixes').

It's untested though reviewable. I should be able to try it this evening.

Francois Romieu (3):
  r8169: decouple the counters data and the device private area.
  r8169: move rtl_reset_counters_cond before the hardware counters helpers.
  r8169: increase the lifespan of the hardware counters dump area.

 drivers/net/ethernet/realtek/r8169.c | 200 +++++++++++++++++------------------
 1 file changed, 96 insertions(+), 104 deletions(-)

-- 
2.4.3
