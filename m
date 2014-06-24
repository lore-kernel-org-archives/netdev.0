From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] trivial: net: filter: Change kerneldoc parameter order
Date: Tue, 24 Jun 2014 15:33:21 +0200
Message-ID: <1403616802-25743-2-git-send-email-tklauser@distanz.ch>
References: <1403616802-25743-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:57138 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752957AbaFXNd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 09:33:56 -0400
In-Reply-To: <1403616802-25743-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the order of the parameters to sk_unattached_filter_create() in
the kerneldoc to reflect the order they appear in the actual function.

This fix is only cosmetic, in the generated doc they still appear in the
correct order without the fix.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/core/filter.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 243fb5d..ed8d929 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1524,8 +1524,8 @@ static struct sk_filter *__sk_prepare_filter(struct sk_filter *fp,
 
 /**
  *	sk_unattached_filter_create - create an unattached filter
- *	@fprog: the filter program
  *	@pfp: the unattached filter that is created
+ *	@fprog: the filter program
  *
  * Create a filter independent of any socket. We first run some
  * sanity checks on it to make sure it does not explode on us later.
-- 
1.7.9.5
