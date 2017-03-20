From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: declare struct sctp_stream before using it
Date: Mon, 20 Mar 2017 17:46:27 +0800
Message-ID: <1a16b414118d0876373774654d86e2a2a936b9d1.1490003187.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35540 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752346AbdCTJzv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 05:55:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_stream_free uses struct sctp_stream as a param, but struct sctp_stream
is defined after it's declaration.

This patch is to declare struct sctp_stream before sctp_stream_free.

Fixes: a83863174a61 ("sctp: prepare asoc stream for stream reconf")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 4f64519..592dece 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -83,6 +83,7 @@ struct sctp_bind_addr;
 struct sctp_ulpq;
 struct sctp_ep_common;
 struct crypto_shash;
+struct sctp_stream;
 
 
 #include <net/sctp/tsnmap.h>
-- 
2.1.0
