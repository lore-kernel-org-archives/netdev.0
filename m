From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/2] ss: Drop silly assignment
Date: Wed, 13 Apr 2016 22:07:04 +0200
Message-ID: <1460578025-12224-2-git-send-email-phil@nwl.cc>
References: <20160329193242.GA28502@orbyte.nwl.cc>
 <1460578025-12224-1-git-send-email-phil@nwl.cc>
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:39837 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751231AbcDMUH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 16:07:26 -0400
In-Reply-To: <1460578025-12224-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An expression of the form '(a | b) & b' will evaluate to the value of b
for any value of a or b.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 38cf3312a746e..d6090018c5dbb 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -267,7 +267,7 @@ static void filter_default_dbs(struct filter *f)
 static void filter_states_set(struct filter *f, int states)
 {
 	if (states)
-		f->states = (f->states | states) & states;
+		f->states = states;
 }
 
 static void filter_merge_defaults(struct filter *f)
-- 
2.8.0
