From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 1/8] lib: EXPORT_SYMBOL sha_init
Date: Mon, 23 Mar 2015 23:35:59 +0100
Message-ID: <c217c8d0d655f62479856e1adff764380f19b154.1427149704.git.hannes@stressinduktion.org>
References: <cover.1427149704.git.hannes@stressinduktion.org>
Cc: ek@google.com, fgont@si6networks.com, lorenzo@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:50954 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752772AbbCWWgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:36:15 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 4A1902079A
	for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 18:36:12 -0400 (EDT)
In-Reply-To: <cover.1427149704.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1427149704.git.hannes@stressinduktion.org>
References: <cover.1427149704.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need this symbol later on in ipv6.ko, thus export it via EXPORT_SYMBOL
like sha_transform already is.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 lib/sha1.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/sha1.c b/lib/sha1.c
index 1df191e..5a56dfd 100644
--- a/lib/sha1.c
+++ b/lib/sha1.c
@@ -198,3 +198,4 @@ void sha_init(__u32 *buf)
 	buf[3] = 0x10325476;
 	buf[4] = 0xc3d2e1f0;
 }
+EXPORT_SYMBOL(sha_init);
-- 
2.1.0
