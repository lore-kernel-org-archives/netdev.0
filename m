From: =?UTF-8?q?Ji=C5=99=C3=AD=20=C5=BDupka?= <jzupka@redhat.com>
Subject: [patch net-next-2.6] Repair wrong named definition aligned_u64
Date: Fri, 30 Sep 2011 14:09:54 +0200
Message-ID: <1317384594-17014-1-git-send-email-jzupka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: loke.chetan@gmail.com, davem@davemloft.net, jpirko@redhat.com,
	=?UTF-8?q?Ji=C5=99=C3=AD=20=C5=BDupka?= <jzupka@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758491Ab1I3MKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Sep 2011 08:10:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This repairs problem with compile library in userspace (libnl).

Signed-off-by: Ji=C5=99=C3=AD =C5=BDupka <jzupka@redhat.com>
---
 include/linux/if_packet.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_packet.h b/include/linux/if_packet.h
index 5e76988..f379929 100644
--- a/include/linux/if_packet.h
+++ b/include/linux/if_packet.h
@@ -173,7 +173,7 @@ struct tpacket_hdr_v1 {
 	 *    you can see which blk[s] is[are] outstanding etc.
 	 * 3. Validate kernel code.
 	 */
-	aligned_u64	seq_num;
+	__aligned_u64	seq_num;
=20
 	/*
 	 * ts_last_pkt:
--=20
1.7.6.4
