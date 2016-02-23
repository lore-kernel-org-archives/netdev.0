From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next v2 0/3] gianfar: xmit() improvements
Date: Tue, 23 Feb 2016 11:48:36 +0200
Message-ID: <1456220919-31440-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0130.outbound.protection.outlook.com ([65.55.169.130]:1664
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751298AbcBWJz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 04:55:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove redundant operations, improve code locality and maintainability.
Thanks.

V2: Updated first patch to not touch existing wmb().

Claudiu Manoil (3):
  gianfar: Map head TxBD first
  gianfar: Use skb_frag_t pointers inside xmit()
  gianfar: Remove redundant ops for do_tstamp from xmit()

 drivers/net/ethernet/freescale/gianfar.c | 100 +++++++++++++++----------------
 1 file changed, 48 insertions(+), 52 deletions(-)

-- 
1.7.11.7
