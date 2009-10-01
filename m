From: Greg KH <gregkh@suse.de>
Subject: [patch 22/30] netfilter: ebt_ulog: fix checkentry return value
Date: Thu, 01 Oct 2009 16:31:38 -0700
Message-ID: <20091001233322.057476155@mini.kroah.org>
References: <20091001233116.947658905@mini.kroah.org>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=netfilter-ebt_ulog-fix-checkentry-return-value.patch
In-Reply-To: <20091001233504.GA17709@kroah.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


2.6.30-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Patrick McHardy <kaber@trash.net>

netfilter: ebt_ulog: fix checkentry return value

Upstream commit 8a56df0a:

Commit 19eda87 (netfilter: change return types of check functions for
Ebtables extensions) broke the ebtables ulog module by missing a return
value conversion.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/bridge/netfilter/ebt_ulog.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -266,7 +266,7 @@ static bool ebt_ulog_tg_check(const stru
 	if (uloginfo->qthreshold > EBT_ULOG_MAX_QLEN)
 		uloginfo->qthreshold = EBT_ULOG_MAX_QLEN;
 
-	return 0;
+	return true;
 }
 
 static struct xt_target ebt_ulog_tg_reg __read_mostly = {


