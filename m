From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 26/26] ipw2100: remove a redundant NULL check before calling
 release_firmware()
Date: Mon, 9 Apr 2012 22:52:34 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092247240.14420@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The release_firmware() function does its own NULL test so a test
before calling it is rather redundant.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index f0551f8..d8d804e 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -8508,8 +8508,7 @@ static void ipw2100_release_firmware(struct ipw2100_priv *priv,
 				     struct ipw2100_fw *fw)
 {
 	fw->version = 0;
-	if (fw->fw_entry)
-		release_firmware(fw->fw_entry);
+	release_firmware(fw->fw_entry);
 	fw->fw_entry = NULL;
 }
 
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
