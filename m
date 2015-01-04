From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] list_nulls: fix missing header
Date: Sun, 4 Jan 2015 15:24:35 +0800
Message-ID: <1420356275-7340-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57334 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbbADHYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 02:24:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixup below build error:

include/linux/list_nulls.h: In function =E2=80=98hlist_nulls_del=E2=80=99=
:
include/linux/list_nulls.h:84:13: error: =E2=80=98LIST_POISON2=E2=80=99=
 undeclared (first use in this function)

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/linux/list_nulls.h |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/list_nulls.h b/include/linux/list_nulls.h
index e8c300e..f266661 100644
--- a/include/linux/list_nulls.h
+++ b/include/linux/list_nulls.h
@@ -1,6 +1,9 @@
 #ifndef _LINUX_LIST_NULLS_H
 #define _LINUX_LIST_NULLS_H
=20
+#include <linux/poison.h>
+#include <linux/const.h>
+
 /*
  * Special version of lists, where end of list is not a NULL pointer,
  * but a 'nulls' marker, which can have many different values.
--=20
1.7.9.5
