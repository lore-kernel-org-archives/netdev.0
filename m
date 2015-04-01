From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] chelsio cxgb/cxgb3: Make stats_strings arrays const
Date: Wed, 01 Apr 2015 08:49:24 -0700
Message-ID: <1427903364.31790.14.camel@perches.com>
References: <1427892333-26330-1-git-send-email-hariprasad@chelsio.com>
	 <1427874122.31790.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, leedom@chelsio.com,
	anish@chelsio.com, nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com, varun@chelsio.com
To: Hariprasad Shenai <hariprasad@chelsio.com>,
	Santosh Raspatur <santosh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0104.hostedemail.com ([216.40.44.104]:33402 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751158AbbDAPt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 11:49:29 -0400
In-Reply-To: <1427874122.31790.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move ~2KB of strings in each driver from data to text.

Signed-off-by: Joe Perches <joe@perches.com>
---

Here a patch for the other 2 drivers

 drivers/net/ethernet/chelsio/cxgb/cxgb2.c       | 2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 186566b..f5f1b0b 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -354,7 +354,7 @@ static void set_msglevel(struct net_device *dev, u32 val)
 	adapter->msg_enable = val;
 }
 
-static char stats_strings[][ETH_GSTRING_LEN] = {
+static const char stats_strings[][ETH_GSTRING_LEN] = {
 	"TxOctetsOK",
 	"TxOctetsBad",
 	"TxUnicastFramesOK",
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index db76f70..b96e4bf 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1537,7 +1537,7 @@ static void set_msglevel(struct net_device *dev, u32 val)
 	adapter->msg_enable = val;
 }
 
-static char stats_strings[][ETH_GSTRING_LEN] = {
+static const char stats_strings[][ETH_GSTRING_LEN] = {
 	"TxOctetsOK         ",
 	"TxFramesOK         ",
 	"TxMulticastFramesOK",
