From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] caif: replace kmalloc/memset 0 by kzalloc
Date: Mon, 13 Oct 2014 22:21:46 +0200
Message-ID: <1413231706-9301-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also add blank line after declaration

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/caif/cfmuxl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/caif/cfmuxl.c b/net/caif/cfmuxl.c
index 8c5d638..510aa5a 100644
--- a/net/caif/cfmuxl.c
+++ b/net/caif/cfmuxl.c
@@ -47,10 +47,10 @@ static struct cflayer *get_up(struct cfmuxl *muxl, u16 id);
 
 struct cflayer *cfmuxl_create(void)
 {
-	struct cfmuxl *this = kmalloc(sizeof(struct cfmuxl), GFP_ATOMIC);
+	struct cfmuxl *this = kzalloc(sizeof(struct cfmuxl), GFP_ATOMIC);
+
 	if (!this)
 		return NULL;
-	memset(this, 0, sizeof(*this));
 	this->layer.receive = cfmuxl_receive;
 	this->layer.transmit = cfmuxl_transmit;
 	this->layer.ctrlcmd = cfmuxl_ctrlcmd;
-- 
1.9.3
