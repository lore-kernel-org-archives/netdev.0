From: Denis Efremov <yefremov.denis@gmail.com>
Subject: [PATCH 05/21] 9p: remove inline marking of EXPORT_SYMBOL functions
Date: Thu,  9 May 2013 11:58:27 +0400
Message-ID: <1368086323-9412-5-git-send-email-yefremov.denis@gmail.com>
References: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com>
Cc: Denis Efremov <yefremov.denis@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	trivial@kernel.org, ldv-project@linuxtesting.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368086241-9357-1-git-send-email-yefremov.denis@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EXPORT_SYMBOL and inline directives are contradictory to each other.
The patch fixes this inconsistency.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Denis Efremov <yefremov.denis@gmail.com>
---
 net/9p/client.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 8eb7542..591c664 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -64,13 +64,13 @@ static const match_table_t tokens = {
 	{Opt_err, NULL},
 };
 
-inline int p9_is_proto_dotl(struct p9_client *clnt)
+int p9_is_proto_dotl(struct p9_client *clnt)
 {
 	return clnt->proto_version == p9_proto_2000L;
 }
 EXPORT_SYMBOL(p9_is_proto_dotl);
 
-inline int p9_is_proto_dotu(struct p9_client *clnt)
+int p9_is_proto_dotu(struct p9_client *clnt)
 {
 	return clnt->proto_version == p9_proto_2000u;
 }
-- 
1.8.1.4
