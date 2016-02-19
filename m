From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next 0/3] gianfar: xmit() improvements
Date: Fri, 19 Feb 2016 12:47:31 +0200
Message-ID: <1455878854-28290-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0129.outbound.protection.outlook.com ([65.55.169.129]:17255
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933511AbcBSLJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 06:09:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some straightforward code improvements for xmit().
Thanks.

Claudiu Manoil (3):
  gianfar: Map head TxBD first to skip a wmb()
  gianfar: Use skb_frag_t pointers inside xmit()
  gianfar: Remove redundant ops for do_tstamp from xmit()

 drivers/net/ethernet/freescale/gianfar.c | 102 +++++++++++++++----------------
 1 file changed, 48 insertions(+), 54 deletions(-)

-- 
1.7.11.7
