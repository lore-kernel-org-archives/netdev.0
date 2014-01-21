From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 5/7] sctp: remove macros sctp_read_[un]lock
Date: Tue, 21 Jan 2014 15:44:10 +0800
Message-ID: <1390290252-16080-6-git-send-email-wangweidong1@huawei.com>
References: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:30319 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbaAUHuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 02:50:01 -0500
In-Reply-To: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redefined read_[un]lock to sctp_read_[un]lock for user space
friendly code which we haven't use in years, and the macros
we never used, so removing them.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sctp/sctp.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 73dcc0c..572cd5a 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -170,10 +170,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
  *  Section:  Macros, externs, and inlines
  */
 
-/* spin lock wrappers. */
-#define sctp_read_lock(lock)    read_lock(lock)
-#define sctp_read_unlock(lock)  read_unlock(lock)
-
 /* sock lock wrappers. */
 #define sctp_lock_sock(sk)       lock_sock(sk)
 #define sctp_release_sock(sk)    release_sock(sk)
-- 
1.7.12
