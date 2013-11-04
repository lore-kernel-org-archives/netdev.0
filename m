From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] lib: crc32: reduce number of cases for crc32{,c}_combine
Date: Mon,  4 Nov 2013 17:10:27 +0100
Message-ID: <c3a8d8671b3d9b7763e3fac7a70be877b8f8ebab.1383580331.git.dborkman@redhat.com>
References: <cover.1383580331.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8235 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753597Ab3KDQKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 11:10:35 -0500
In-Reply-To: <cover.1383580331.git.dborkman@redhat.com>
In-Reply-To: <cover.1383580331.git.dborkman@redhat.com>
References: <cover.1383580331.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can safely reduce the number of test cases by a tenth.
There is no particular need to run as many as we're running
now for crc32{,c}_combine, that gives us still ~8000 tests
we're doing if people run kernels with crc selftests enabled
which is perfectly fine.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 lib/crc32.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/crc32.c b/lib/crc32.c
index 3a1dfa8..70f00ca 100644
--- a/lib/crc32.c
+++ b/lib/crc32.c
@@ -1037,7 +1037,7 @@ static int __init crc32c_combine_test(void)
 	int i, j;
 	int errors = 0, runs = 0;
 
-	for (i = 0; i < 100; i++) {
+	for (i = 0; i < 10; i++) {
 		u32 crc_full;
 
 		crc_full = __crc32c_le(test[i].crc, test_buf + test[i].start,
@@ -1131,7 +1131,7 @@ static int __init crc32_combine_test(void)
 	int i, j;
 	int errors = 0, runs = 0;
 
-	for (i = 0; i < 100; i++) {
+	for (i = 0; i < 10; i++) {
 		u32 crc_full;
 
 		crc_full = crc32_le(test[i].crc, test_buf + test[i].start,
-- 
1.8.3.1
