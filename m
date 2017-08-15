From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 5/5] net/9p: Delete an unnecessary variable initialisation in
 p9_client_attach()
Date: Tue, 15 Aug 2017 14:03:19 +0200
Message-ID: <ec7726a4-ef2e-4f26-a218-2889617124d1@users.sourceforge.net>
References: <22a44d7c-cdb9-e206-4b2c-56e38cbf0de1@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Ron Minnich <rminnich@sandia.gov>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <22a44d7c-cdb9-e206-4b2c-56e38cbf0de1@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 15 Aug 2017 11:25:31 +0200

The local variable "err" will eventually be set to an appropriate value
a bit later. Thus omit the explicit initialisation at the beginning.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/9p/client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 38c08171acc6..1d59db9aafb3 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -1124,7 +1124,7 @@ EXPORT_SYMBOL(p9_client_begin_disconnect);
 struct p9_fid *p9_client_attach(struct p9_client *clnt, struct p9_fid *afid,
 	const char *uname, kuid_t n_uname, const char *aname)
 {
-	int err = 0;
+	int err;
 	struct p9_req_t *req;
 	struct p9_fid *fid;
 	struct p9_qid qid;
-- 
2.14.0
