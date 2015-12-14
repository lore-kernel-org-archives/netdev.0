From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] net: fix warnings in 'make htmldocs' by moving macro definition out of field declaration
Date: Mon, 14 Dec 2015 23:30:43 +0100
Message-ID: <1450132243-12741-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:60422 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932382AbbLNWaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 17:30:55 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 534D6213C0
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 17:30:54 -0500 (EST)
Received: from z.com (unknown [213.55.184.189])
	by mail.messagingengine.com (Postfix) with ESMTPA id 8207FC016DA
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 17:30:53 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Docbook does not like the definition of macros inside a field declaration
and adds a warning. Move the definition out.

Fixes: 79462ad02e86180 ("net: add validation for the socket syscall protocol argument")
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/sock.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c4205e0a3a2d28..47ad810c1ca48f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -403,8 +403,8 @@ struct sock {
 				sk_no_check_rx : 1,
 				sk_userlocks : 4,
 				sk_protocol  : 8,
-#define SK_PROTOCOL_MAX U8_MAX
 				sk_type      : 16;
+#define SK_PROTOCOL_MAX U8_MAX
 	kmemcheck_bitfield_end(flags);
 	int			sk_wmem_queued;
 	gfp_t			sk_allocation;
-- 
2.5.0
