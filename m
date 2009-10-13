From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] cnic: Fix build error on powerpc.
Date: Mon, 12 Oct 2009 22:42:13 -0700
Message-ID: <1255412533-28136-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1578 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782AbZJMFeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 01:34:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing #include <net/ip6_checksum.h>

Problem noted by Stephen Rothwell.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 6e7af7b..333b1d1 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -33,6 +33,7 @@
 #include <net/route.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/ip6_checksum.h>
 #include <scsi/iscsi_if.h>
 
 #include "cnic_if.h"
-- 
1.6.4.GIT


