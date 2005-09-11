From: Ralf Baechle DL5RB <ralf@linux-mips.org>
Subject: [PATCH  5/12] Add descriptions to constants
Date: Sun, 11 Sep 2005 23:19:04 +0100
Message-ID: <20050911221904.GA9301@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Comment the names used for the AX.25 state machine.

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 include/net/ax25.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

Index: linux-cvs/include/net/ax25.h
===================================================================
--- linux-cvs.orig/include/net/ax25.h
+++ linux-cvs/include/net/ax25.h
@@ -97,11 +97,11 @@
 /* Define Link State constants. */
 
 enum { 
-	AX25_STATE_0,
-	AX25_STATE_1,
-	AX25_STATE_2,
-	AX25_STATE_3,
-	AX25_STATE_4
+	AX25_STATE_0,			/* Listening */
+	AX25_STATE_1,			/* SABM sent */
+	AX25_STATE_2,			/* DISC sent */
+	AX25_STATE_3,			/* Established */
+	AX25_STATE_4			/* Recovery */
 };
 
 #define AX25_MODULUS 		8	/*  Standard AX.25 modulus */
