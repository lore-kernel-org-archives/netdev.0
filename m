From: Andrey Utkin <andrey.krieger.utkin@gmail.com>
Subject: [PATCH 2/5] net/rxrpc/ar-key.c: drop negativity check on unsigned value
Date: Fri, 18 Jul 2014 18:31:57 +0300
Message-ID: <1405697517-23673-1-git-send-email-andrey.krieger.utkin@gmail.com>
Cc: dcb314@hotmail.com, nwf@cs.jhu.edu, dhowells@redhat.com,
	davem@davemloft.net, Andrey Utkin <andrey.krieger.utkin@gmail.com>
To: linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=80611
Reported-by: David Binderman <dcb314@hotmail.com>
Signed-off-by: Andrey Utkin <andrey.krieger.utkin@gmail.com>
---
 net/rxrpc/ar-key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index 0ad0807..eec998e 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -346,7 +346,7 @@ static int rxrpc_krb5_decode_tagged_array(struct krb5_tagged_data **_td,
 
 	n_elem = ntohl(*xdr++);
 	toklen -= 4;
-	if (n_elem < 0 || n_elem > max_n_elem)
+	if (n_elem > max_n_elem)
 		return -EINVAL;
 	*_n_elem = n_elem;
 	if (n_elem > 0) {
-- 
1.8.5.5
