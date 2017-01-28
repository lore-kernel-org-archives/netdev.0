From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/4] dcbnl: Add some spaces for better code readability
Date: Sat, 28 Jan 2017 10:37:39 +0100
Message-ID: <37fec5d3-4697-f3b9-b780-d11585a0f494@users.sourceforge.net>
References: <ab981a3f-e73e-9bef-09c5-9c6d077aef00@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Pan Bian <bianpan2016@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab981a3f-e73e-9bef-09c5-9c6d077aef00@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 28 Jan 2017 10:15:59 +0100

Use space characters at some source code places according to
the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/dcb/dcbnl.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 0903081a1212..0150de92c8ba 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -315,7 +315,7 @@ static int dcbnl_getcap(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (data[DCB_CAP_ATTR_ALL])
 		getall = 1;
 
-	for (i = DCB_CAP_ATTR_ALL+1; i <= DCB_CAP_ATTR_MAX; i++) {
+	for (i = DCB_CAP_ATTR_ALL + 1; i <= DCB_CAP_ATTR_MAX; i++) {
 		if (!getall && !data[i])
 			continue;
 
@@ -359,7 +359,7 @@ static int dcbnl_getnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (data[DCB_NUMTCS_ATTR_ALL])
 		getall = 1;
 
-	for (i = DCB_NUMTCS_ATTR_ALL+1; i <= DCB_NUMTCS_ATTR_MAX; i++) {
+	for (i = DCB_NUMTCS_ATTR_ALL + 1; i <= DCB_NUMTCS_ATTR_MAX; i++) {
 		if (!getall && !data[i])
 			continue;
 
@@ -397,7 +397,7 @@ static int dcbnl_setnumtcs(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (ret)
 		return ret;
 
-	for (i = DCB_NUMTCS_ATTR_ALL+1; i <= DCB_NUMTCS_ATTR_MAX; i++) {
+	for (i = DCB_NUMTCS_ATTR_ALL + 1; i <= DCB_NUMTCS_ATTR_MAX; i++) {
 		if (!data[i])
 			continue;
 
@@ -1593,7 +1593,7 @@ static int dcbnl_getfeatcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (data[DCB_FEATCFG_ATTR_ALL])
 		getall = 1;
 
-	for (i = DCB_FEATCFG_ATTR_ALL+1; i <= DCB_FEATCFG_ATTR_MAX; i++) {
+	for (i = DCB_FEATCFG_ATTR_ALL + 1; i <= DCB_FEATCFG_ATTR_MAX; i++) {
 		if (!getall && !data[i])
 			continue;
 
@@ -1631,7 +1631,7 @@ static int dcbnl_setfeatcfg(struct net_device *netdev, struct nlmsghdr *nlh,
 	if (ret)
 		goto err;
 
-	for (i = DCB_FEATCFG_ATTR_ALL+1; i <= DCB_FEATCFG_ATTR_MAX; i++) {
+	for (i = DCB_FEATCFG_ATTR_ALL + 1; i <= DCB_FEATCFG_ATTR_MAX; i++) {
 		if (!data[i])
 			continue;
 
@@ -1669,7 +1669,7 @@ struct reply_func {
 		    struct nlattr **, struct sk_buff *);
 };
 
-static const struct reply_func reply_funcs[DCB_CMD_MAX+1] = {
+static const struct reply_func reply_funcs[DCB_CMD_MAX + 1] = {
 	[DCB_CMD_GSTATE]	= { RTM_GETDCB, dcbnl_getstate },
 	[DCB_CMD_SSTATE]	= { RTM_SETDCB, dcbnl_setstate },
 	[DCB_CMD_PFC_GCFG]	= { RTM_GETDCB, dcbnl_getpfccfg },
-- 
2.11.0
