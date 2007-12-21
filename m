From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] IPv4: Fix a typo in tcp_v4_do_calc_md5_hash() which prevents
	compilation
Date: Fri, 21 Dec 2007 08:47:13 -0500
Message-ID: <20071221134713.10228.50057.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:56218
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762020AbXLUN5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 08:57:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's spelled "unsigned".

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 net/ipv4/tcp_ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9cb92b8..9aea88b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1020,7 +1020,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 				   __be32 saddr, __be32 daddr,
 				   struct tcphdr *th, int protocol,
-				   unsinged int tcplen)
+				   unsigned int tcplen)
 {
 	struct scatterlist sg[4];
 	__u16 data_len;

