From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [PATCH 1/7] In police, fix uninitialized "overhead" variable.
Date: Wed, 9 Apr 2008 22:59:41 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804092258150.21022@ask.diku.dk>
References: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:32983 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754836AbYDIU7p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 16:59:45 -0400
In-Reply-To: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Bug introduced by myself in an earlier patch series.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---
  tc/m_police.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/m_police.c b/tc/m_police.c
index 8fa63ad..e55a8c9 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -133,7 +133,7 @@ int act_parse_police(struct action_util *a,int *argc_p, char ***argv_p, int tca_
  	__u32 avrate = 0;
  	int presult = 0;
  	unsigned buffer=0, mtu=0, mpu=0;
-	unsigned short overhead;
+	unsigned short overhead=0;
  	int Rcell_log=-1, Pcell_log = -1;
  	struct rtattr *tail;

-- 
1.5.3

