From: Carl Spalletta <cspalletta@yahoo.com>
Subject: [PATCH] Remove prototypes of nonexistent functions from net/sctp files
Date: Sun, 18 Jul 2004 12:48:26 -0700 (PDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040718194826.6164.qmail@web53805.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262418AbUGRTs1@vger.kernel.org>
To: lkml <linux-kernel@vger.kernel.org>
List-Id: netdev.vger.kernel.org

diff -ru linux-2.6.7-orig/net/sctp/socket.c linux-2.6.7-new/net/sctp/socket.c
--- linux-2.6.7-orig/net/sctp/socket.c  2004-06-15 22:20:26.000000000 -0700
+++ linux-2.6.7-new/net/sctp/socket.c   2004-07-18 08:54:08.000000000 -0700
@@ -109,7 +109,6 @@
 static char *sctp_hmac_alg = SCTP_COOKIE_HMAC_ALG;

 extern kmem_cache_t *sctp_bucket_cachep;
-extern int sctp_assoc_valid(struct sock *sk, struct sctp_association *asoc);

 /* Look up the association by its id.  If this is not a UDP-style
  * socket, the ID field is always ignored.
