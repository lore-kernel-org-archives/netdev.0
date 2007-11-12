From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ethtool: Fix coalesce settings copy+paste typo
Date: Mon, 12 Nov 2007 10:28:42 -0800
Message-ID: <20071112182842.24618.61654.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64871 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133AbXKLS2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2007 13:28:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Coalesce setting errors use the same error messages as the
descriptor ring errors.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 6c7a2e3..bb9dd59 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1470,7 +1470,7 @@ static int do_scoalesce(int fd, struct ifreq *ifr)
 		       &changed);
 
 	if (!changed) {
-		fprintf(stderr, "no ring parameters changed, aborting\n");
+		fprintf(stderr, "no coalesce parameters changed, aborting\n");
 		return 80;
 	}
 
@@ -1478,7 +1478,7 @@ static int do_scoalesce(int fd, struct ifreq *ifr)
 	ifr->ifr_data = (caddr_t)&ecoal;
 	err = ioctl(fd, SIOCETHTOOL, ifr);
 	if (err) {
-		perror("Cannot set device ring parameters");
+		perror("Cannot set device coalesce parameters");
 		return 81;
 	}
 
