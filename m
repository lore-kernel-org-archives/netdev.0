From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: linux-next: Tree for July 16 (net/bnx2x)
Date: Sat, 16 Jul 2011 23:30:56 +0300
Message-ID: <1310848256.2826.3.camel@lb-tlvb-dmitry>
References: <20110717000815.c83755be9598d34ac8431908@canb.auug.org.au>
 <20110716121427.11760128.rdunlap@xenotime.net>
 <1310847842.2826.1.camel@lb-tlvb-dmitry>
 <20110716.132643.101780166611692580.davem@davemloft.net>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "rdunlap@xenotime.net" <rdunlap@xenotime.net>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110716.132643.101780166611692580.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-07-16 at 13:26 -0700, David Miller wrote:
> From: "Dmitry Kravkov" <dmitry@broadcom.com>
> Date: Sat, 16 Jul 2011 23:24:02 +0300
> 
> > @@ -1403,8 +1403,8 @@ void bnx2x_netif_stop(struct bnx2x *bp, int
> > disable_hw)
> >  
> 
> Patch corrupted by your email client, this long line was chopped
> up into two lines.
> 
bnx2x: Fix compilation when CNIC is not selected in config

Reported-by:  Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index e5fac62..b05ce93 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1403,8 +1403,8 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 
 u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-#ifdef BCM_CNIC
 	struct bnx2x *bp = netdev_priv(dev);
+#ifdef BCM_CNIC
 	if (NO_FCOE(bp))
 		return skb_tx_hash(dev, skb);
 	else {
-- 
1.7.2.2
