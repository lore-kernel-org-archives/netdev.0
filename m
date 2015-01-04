From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] rhashtable: fix missing header
Date: Sun, 4 Jan 2015 15:25:09 +0800
Message-ID: <1420356309-7382-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57374 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbbADHZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 02:25:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixup below build error:

include/linux/rhashtable.h: At top level:
include/linux/rhashtable.h:118:34: error: field =E2=80=98mutex=E2=80=99=
 has incomplete type

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/linux/rhashtable.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index de7cac7..de1459c7 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -20,6 +20,7 @@
=20
 #include <linux/list_nulls.h>
 #include <linux/workqueue.h>
+#include <linux/mutex.h>
=20
 /*
  * The end of the chain is marked with a special nulls marks which has
--=20
1.7.9.5
