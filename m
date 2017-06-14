From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 1/2] tc: m_tunnel_key: reformat the usage text
Date: Wed, 14 Jun 2017 21:29:49 +0200
Message-ID: <20170614212949.53cf62d4@griffin>
References: <cover.1497467840.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51538 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752080AbdFNT3x (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 15:29:53 -0400
In-Reply-To: <cover.1497467840.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding new tunnel key fields would cause the usage line overflow 80 chars.
Make the usage text similar to other commands.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 tc/m_tunnel_key.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/tc/m_tunnel_key.c b/tc/m_tunnel_key.c
index fb418a76bd79..6faf9632058a 100644
--- a/tc/m_tunnel_key.c
+++ b/tc/m_tunnel_key.c
@@ -22,7 +22,13 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: tunnel_key unset\n");
-	fprintf(stderr, "       tunnel_key set id TUNNELID src_ip IP dst_ip IP dst_port UDP_PORT\n");
+	fprintf(stderr, "       tunnel_key set <TUNNEL_KEY>\n");
+	fprintf(stderr,
+		"Where TUNNEL_KEY is a combination of:\n"
+		"id <TUNNELID> (mandatory)\n"
+		"src_ip <IP> (mandatory)\n"
+		"dst_ip <IP> (mandatory)\n"
+		"dst_port <UDP_PORT>\n");
 }
 
 static void usage(void)
-- 
1.8.3.1
