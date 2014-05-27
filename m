From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] [TRIVIAL] atm: remove commented out check
Date: Tue, 27 May 2014 17:07:12 +0200
Message-ID: <1401203232.28714.10.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This preprocessor check is commented out ever since this file was added
during the v2.3 development cycle. It is unclear what it purpose might
have been. Whatever it was, it can safely be removed now.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Compile tested.

Perhaps someone on netdev knows what CONFIG_SINGLE_SIGITF might have
been for. Not that it actually matters.

 net/atm/svc.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/net/atm/svc.c b/net/atm/svc.c
index 1281049c135f..d8e5d0c2ebbc 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -263,17 +263,11 @@ static int svc_connect(struct socket *sock, struct sockaddr *sockaddr,
 			goto out;
 		}
 	}
-/*
- * Not supported yet
- *
- * #ifndef CONFIG_SINGLE_SIGITF
- */
+
 	vcc->qos.txtp.max_pcr = SELECT_TOP_PCR(vcc->qos.txtp);
 	vcc->qos.txtp.pcr = 0;
 	vcc->qos.txtp.min_pcr = 0;
-/*
- * #endif
- */
+
 	error = vcc_connect(sock, vcc->itf, vcc->vpi, vcc->vci);
 	if (!error)
 		sock->state = SS_CONNECTED;
-- 
1.9.3
