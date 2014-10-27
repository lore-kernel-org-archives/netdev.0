From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] ipv6: replace min/casting by min_t
Date: Mon, 27 Oct 2014 19:11:56 +0100
Message-ID: <1414433516-29278-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv6/addrconf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 725c763..50b95b2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2315,8 +2315,8 @@ ok:
 			else
 				stored_lft = 0;
 			if (!update_lft && !create && stored_lft) {
-				const u32 minimum_lft = min(
-					stored_lft, (u32)MIN_VALID_LIFETIME);
+				const u32 minimum_lft = min_t(u32,
+					stored_lft, MIN_VALID_LIFETIME);
 				valid_lft = max(valid_lft, minimum_lft);
 
 				/* RFC4862 Section 5.5.3e:
-- 
1.9.1
