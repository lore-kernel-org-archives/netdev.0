From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] af_unix: constify the sock parameter in unix_sk()
Date: Tue, 06 Oct 2015 15:03:53 -0400
Message-ID: <20151006190353.7311.36864.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35707 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752456AbbJFTDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 15:03:54 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id A625A8E70F
	for <netdev@vger.kernel.org>; Tue,  6 Oct 2015 19:03:54 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make unix_sk() just like inet[6]_sk() by constify'ing the sock
parameter.

Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 include/net/af_unix.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index cb1b9bb..b36d837 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -64,7 +64,7 @@ struct unix_sock {
 	struct socket_wq	peer_wq;
 };
 
-static inline struct unix_sock *unix_sk(struct sock *sk)
+static inline struct unix_sock *unix_sk(const struct sock *sk)
 {
 	return (struct unix_sock *)sk;
 }
