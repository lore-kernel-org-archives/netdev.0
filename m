From: Mika Kukkonen <mikukkon@iki.fi>
Subject: [PATCH] NETROM: Fix three if-statements in nr_state1_machine()
Date: Wed, 21 Dec 2005 22:15:13 +0200
Message-ID: <20051221201513.GB24213@localhost.localdomain>
Reply-To: mikukkon@iki.fi
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964814AbVLUUQP@vger.kernel.org>
To: ralf@linux-mips.org, netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I found these while compiling with extra gcc warnings;
considering the indenting surely they are not intentional?

Signed-of-by: Mika Kukkonen <mikukkon@iki.fi>

---

 net/netrom/nr_in.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netrom/nr_in.c b/net/netrom/nr_in.c
index 004e859..a7d88b5 100644
--- a/net/netrom/nr_in.c
+++ b/net/netrom/nr_in.c
@@ -99,7 +99,7 @@ static int nr_state1_machine(struct sock
 		break;
 
 	case NR_RESET:
-		if (sysctl_netrom_reset_circuit);
+		if (sysctl_netrom_reset_circuit)
 			nr_disconnect(sk, ECONNRESET);
 		break;
 
@@ -130,7 +130,7 @@ static int nr_state2_machine(struct sock
 		break;
 
 	case NR_RESET:
-		if (sysctl_netrom_reset_circuit);
+		if (sysctl_netrom_reset_circuit)
 			nr_disconnect(sk, ECONNRESET);
 		break;
 
@@ -265,7 +265,7 @@ static int nr_state3_machine(struct sock
 		break;
 
 	case NR_RESET:
-		if (sysctl_netrom_reset_circuit);
+		if (sysctl_netrom_reset_circuit)
 			nr_disconnect(sk, ECONNRESET);
 		break;
 
