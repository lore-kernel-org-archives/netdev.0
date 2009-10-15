From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH 6/8] trivial: fix typo s/refference/reference/ in comment
Date: Thu, 15 Oct 2009 17:16:23 -0300
Message-ID: <1255637783-6109-1-git-send-email-cascardo@holoscopio.com>
Cc: Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Wang Chen <wangchen@cn.fujitsu.com>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: trivial@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935473AbZJOURL@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 net/bluetooth/bnep/core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index cafe9f5..1bd9398 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -78,7 +78,7 @@ static struct bnep_session *__bnep_get_session(u8 *dst)
 static void __bnep_link_session(struct bnep_session *s)
 {
 	/* It's safe to call __module_get() here because sessions are added
-	   by the socket layer which has to hold the refference to this module.
+	   by the socket layer which has to hold the reference to this module.
 	 */
 	__module_get(THIS_MODULE);
 	list_add(&s->list, &bnep_session_list);
-- 
1.6.3.3
