From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 04/11] sctp: remove the typedef sctp_hostname_param_t
Date: Mon, 17 Jul 2017 11:29:52 +0800
Message-ID: <7faff4d9e2bef97652b742006c0165641ad84504.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
 <cadd1baef89e215244af82032957ccde1189bcc8.1500261974.git.lucien.xin@gmail.com>
 <0add39ae0879e3b332bafc24aa6ccdb6b0d5c85a.1500261974.git.lucien.xin@gmail.com>
 <c8cdb622f7de0edc639936e3fa15a262e92cfa66.1500261974.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36065 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751248AbdGQDal (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Jul 2017 23:30:41 -0400
In-Reply-To: <c8cdb622f7de0edc639936e3fa15a262e92cfa66.1500261974.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1500261974.git.lucien.xin@gmail.com>
References: <cover.1500261974.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove this typedef, there is even no places using it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index d8f9d8f..c43e906 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -291,10 +291,10 @@ struct sctp_cookie_preserve_param {
 };
 
 /* Section 3.3.2.1 Host Name Address (11) */
-typedef struct sctp_hostname_param {
+struct sctp_hostname_param {
 	struct sctp_paramhdr param_hdr;
 	uint8_t hostname[0];
-} sctp_hostname_param_t;
+};
 
 /* Section 3.3.2.1 Supported Address Types (12) */
 typedef struct sctp_supported_addrs_param {
-- 
2.1.0
