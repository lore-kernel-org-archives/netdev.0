From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/12] sunrpc: Use DECLARE_BITMAP
Date: Tue, 19 May 2015 18:38:00 -0700
Message-ID: <ddf7dec5616d4e0fda0f9f2a31202dc80027f30a.1432085659.git.joe@perches.com>
References: <cover.1432085659.git.joe@perches.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1432085659.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the generic mechanism to declare a bitmap instead of unsigned long.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1095be9..e417476 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -320,7 +320,7 @@ struct gss_svc_seq_data {
 	int			sd_max;
 	/* for i such that sd_max-GSS_SEQ_WIN < i <= sd_max, the i-th bit of
 	 * sd_win is nonzero iff sequence number i has been seen already: */
-	unsigned long		sd_win[GSS_SEQ_WIN/BITS_PER_LONG];
+	DECLARE_BITMAP(sd_win, GSS_SEQ_WIN);
 	spinlock_t		sd_lock;
 };
 
-- 
2.1.2
