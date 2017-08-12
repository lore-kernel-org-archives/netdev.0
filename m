From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 37/51] netem/maketable: Check return value of fscanf()
Date: Sat, 12 Aug 2017 14:04:56 +0200
Message-ID: <20170812120510.28750-38-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33861 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751977AbdHLMJe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:09:34 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 netem/maketable.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/netem/maketable.c b/netem/maketable.c
index ad660e7d457f0..ccb8f0c68b062 100644
--- a/netem/maketable.c
+++ b/netem/maketable.c
@@ -38,8 +38,8 @@ readdoubles(FILE *fp, int *number)
 	}
 
 	for (i=0; i<limit; ++i){
-		fscanf(fp, "%lf", &x[i]);
-		if (feof(fp))
+		if (fscanf(fp, "%lf", &x[i]) != 1 ||
+		    feof(fp))
 			break;
 		++n;
 	}
-- 
2.13.1
