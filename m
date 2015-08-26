From: Valentin Rothberg <valentinrothberg@gmail.com>
Subject: [PATCH] lib/Makefile: remove CONFIG_AVERAGE build rule
Date: Wed, 26 Aug 2015 15:36:12 +0200
Message-ID: <20150826133612.GA31643@faui49jenkins20.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Valentin Rothberg <valentinrothberg@gmail.com>
To: johannes.berg@intel.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36857 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbHZNgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 09:36:19 -0400
Content-Description: =?ISO-8859-1?Q?=20=1B?=
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Kconfig option AVERAGE and its implementation has been removed by
commit f4e774f55fe0 ("average: remove out-of-line implementation").
Remove the dead build rule in lib/Makefile.

Signed-off-by: Valentin Rothberg <valentinrothberg@gmail.com>
Reviewed-by: Johannes Berg <johannes@sipsolutions.net>
---
I detected the issue with scripts/checkkconfigsymbols.py
David asked to resend the full patch netdev so that it gets queued
up in patchwork.

 lib/Makefile | 2 --
 1 file changed, 2 deletions(-)

diff --git a/lib/Makefile b/lib/Makefile
index 51e1d761f0b9..f32d342b75de 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -143,8 +143,6 @@ obj-$(CONFIG_GENERIC_ATOMIC64) += atomic64.o
 
 obj-$(CONFIG_ATOMIC64_SELFTEST) += atomic64_test.o
 
-obj-$(CONFIG_AVERAGE) += average.o
-
 obj-$(CONFIG_CPU_RMAP) += cpu_rmap.o
 
 obj-$(CONFIG_CORDIC) += cordic.o
-- 
1.9.1
