From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 1/2] tc: Remove unused variable 'res'.
Date: Wed, 23 Nov 2011 22:13:23 +0100
Message-ID: <4ECD61F3.4040504@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:43784 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248Ab1KWVN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 16:13:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by cppcheck.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 tc/m_ipt.c    |    2 --
 tc/m_xt_old.c |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/tc/m_ipt.c b/tc/m_ipt.c
index a73d400..b8655f8 100644
--- a/tc/m_ipt.c
+++ b/tc/m_ipt.c
@@ -396,11 +396,9 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 	char **argv = *argv_p;
 	int argc = 0, iargc = 0;
 	char k[16];
-	int res = -1;
 	int size = 0;
 	int iok = 0, ok = 0;
 	__u32 hook = 0, index = 0;
-	res = 0;
 
 	lib_dir = getenv("IPTABLES_LIB_DIR");
 	if (!lib_dir)
diff --git a/tc/m_xt_old.c b/tc/m_xt_old.c
index 3804d7f..7ed7ecc 100644
--- a/tc/m_xt_old.c
+++ b/tc/m_xt_old.c
@@ -215,11 +215,9 @@ static int parse_ipt(struct action_util *a,int *argc_p,
 	char **argv = *argv_p;
 	int argc = 0, iargc = 0;
 	char k[16];
-	int res = -1;
 	int size = 0;
 	int iok = 0, ok = 0;
 	__u32 hook = 0, index = 0;
-	res = 0;
 
 	set_lib_dir();
 
-- 
1.7.6.4
