From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 09/14] sctp: remove the typedef sctp_cwr_chunk_t
Date: Thu,  3 Aug 2017 15:42:17 +0800
Message-ID: <4117cc15ad262c164f9725e4dee1f9d0b13dd992.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
 <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
 <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
 <61746e2a2efa75634ab632cf264ad902aa3f9685.1501745729.git.lucien.xin@gmail.com>
 <91fc6fd265b6623a2244f17a9e5581962a2183d0.1501745729.git.lucien.xin@gmail.com>
 <bc49ca93eba1ba96461674afe5fadc441f8d288a.1501745729.git.lucien.xin@gmail.com>
 <a5a3e5ce57d84377d2426a010f92d2afb5ca346d.1501745729.git.lucien.xin@gmail.com>
 <cd4fd6410dd3ee98ea8462b2b9eb8af3b39d536a.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33878 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751032AbdHCHoH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:44:07 -0400
In-Reply-To: <cd4fd6410dd3ee98ea8462b2b9eb8af3b39d536a.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove this typedef including the struct, there is even no places
using it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 3c8c418..2a97639 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -535,11 +535,6 @@ struct sctp_cwrhdr {
 	__be32 lowest_tsn;
 };
 
-typedef struct sctp_cwr_chunk {
-	struct sctp_chunkhdr chunk_hdr;
-	struct sctp_cwrhdr cwr_hdr;
-} sctp_cwr_chunk_t;
-
 /* PR-SCTP
  * 3.2 Forward Cumulative TSN Chunk Definition (FORWARD TSN)
  *
-- 
2.1.0
