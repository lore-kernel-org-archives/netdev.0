From: Li Yewang <lyw@cn.fujitsu.com>
Subject: [patch][ipsec] can not add camellia cipher algorithm when using "ip
 xfrm state"  command
Date: Mon, 30 Nov 2009 09:39:29 +0800
Message-ID: <4B132251.5060806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61333 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752997AbZK3Bjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2009 20:39:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

can not add camellia cipher algorithm when using "ip xfrm state" command.

Signed-off-by: Li Yewang <lyw@cn.fujitsu.com>

---
 net/xfrm/xfrm_algo.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index faf54c6..348196d 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -365,6 +365,7 @@ static struct xfrm_algo_desc ealg_list[] = {
 },
 {
 	.name = "cbc(camellia)",
+	.compat = "camellia",
 
 	.uinfo = {
 		.encr = {
-- 
1.6.4.1

