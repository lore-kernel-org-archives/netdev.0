From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] xfrm_user: avoid a warning with some compiler
Date: Tue, 31 Aug 2010 17:54:00 +0200
Message-ID: <4C7D2598.5070400@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000907080507040105060505"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53941 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932422Ab0HaPyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 11:54:04 -0400
Received: by wyb35 with SMTP id 35so8036564wyb.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 08:54:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000907080507040105060505
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Attached is a small patch to remove a warning ("warning: ISO C90 forbids 
mixed declarations and code" with gcc 4.3.2).

Regards,
Nicolas

--------------000907080507040105060505
Content-Type: text/x-diff;
 name="0001-xfrm_user-avoid-a-warning-with-some-compiler.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-xfrm_user-avoid-a-warning-with-some-compiler.patch"

>From 94b066b7f650bda6ef1392a18c5d3014bcc05d6a Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 31 Aug 2010 17:41:05 +0200
Subject: [PATCH] xfrm_user: avoid a warning with some compiler

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/xfrm/xfrm_user.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b14ed4b..8bae6b2 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1801,7 +1801,7 @@ static int xfrm_add_sa_expire(struct sk_buff *skb, struct nlmsghdr *nlh,
 	struct xfrm_user_expire *ue = nlmsg_data(nlh);
 	struct xfrm_usersa_info *p = &ue->state;
 	struct xfrm_mark m;
-	u32 mark = xfrm_mark_get(attrs, &m);;
+	u32 mark = xfrm_mark_get(attrs, &m);
 
 	x = xfrm_state_lookup(net, mark, &p->id.daddr, p->id.spi, p->id.proto, p->family);
 
-- 
1.5.6.5


--------------000907080507040105060505--
