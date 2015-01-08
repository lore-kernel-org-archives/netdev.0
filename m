From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net 2/2] gen_stats.c: Fix comment above
 gnet_stats_start_copy()
Date: Thu, 8 Jan 2015 11:35:36 +0100
Message-ID: <20150108103536.GA7237@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:53971 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753784AbbAHKvr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2015 05:51:47 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Y9ARc-0003lQ-IX
	for netdev@vger.kernel.org; Thu, 08 Jan 2015 11:36:00 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Y9ARE-0001su-Um
	for netdev@vger.kernel.org; Thu, 08 Jan 2015 11:35:37 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original comment was obviously a failed copy/paste.

Signed-off-by: Ignacy Gaw=EAdzki <ignacy.gawedzki@green-communications.=
fr>
---
 net/core/gen_stats.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 5770a0e..1b25d80 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -77,7 +77,7 @@ gnet_stats_start_copy_compat(struct sk_buff *skb, int=
 type, int tc_stats_type,
 EXPORT_SYMBOL(gnet_stats_start_copy_compat);
=20
 /**
- * gnet_stats_start_copy_compat - start dumping procedure in compatibi=
lity mode
+ * gnet_stats_start_copy - start dumping procedure
  * @skb: socket buffer to put statistics TLVs into
  * @type: TLV type for top level statistic TLV
  * @lock: statistics lock
--=20
1.9.1
