From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH -next] netdev: inet_timewait_sock.h missing semi-colon when
 KMEMCHECK is enabled
Date: Mon, 14 Oct 2013 12:36:32 -0700
Message-ID: <525C47C0.2000907@infradead.org>
References: <1381762088-18880-1-git-send-email-treding@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Thierry Reding <thierry.reding@gmail.com>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1381762088-18880-1-git-send-email-treding@nvidia.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@infradead.org>

Fix (a few hundred) build errors due to missing semi-colon when
KMEMCHECK is enabled:

  include/net/inet_timewait_sock.h:139:2: error: expected ',', ';' or '}' before 'int'
  include/net/inet_timewait_sock.h:148:28: error: 'const struct inet_timewait_sock' has no member named 'tw_death_node'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 include/net/inet_timewait_sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- next-2013-1014.orig/include/net/inet_timewait_sock.h
+++ next-2013-1014/include/net/inet_timewait_sock.h
@@ -135,7 +135,7 @@ struct inet_timewait_sock {
 				tw_transparent  : 1,
 				tw_pad		: 6,	/* 6 bits hole */
 				tw_tos		: 8,
-				tw_pad2		: 16 /* 16 bits hole */
+				tw_pad2		: 16;	/* 16 bits hole */
 	kmemcheck_bitfield_end(flags);
 	u32			tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
