From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 3/3] Define cipso_v4_delopt static
Date: Wed,  7 Oct 2009 23:34:42 +0200
Message-ID: <1254951282-5056-4-git-send-email-hagen@jauu.net>
References: <1254951282-5056-1-git-send-email-hagen@jauu.net>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:35215 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753356AbZJGVod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 17:44:33 -0400
In-Reply-To: <1254951282-5056-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason that cipso_v4_delopt() is not
defined as a static function.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv4/cipso_ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index 039cc1f..1e029dc 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -2017,7 +2017,7 @@ req_setattr_failure:
  * values on failure.
  *
  */
-int cipso_v4_delopt(struct ip_options **opt_ptr)
+static int cipso_v4_delopt(struct ip_options **opt_ptr)
 {
 	int hdr_delta = 0;
 	struct ip_options *opt = *opt_ptr;
-- 
1.6.3.GIT

