From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: linux-next: Tree for Aug 29 (bnx2x)
Date: Tue, 30 Aug 2011 00:35:44 +0300
Message-ID: <1314653744.3085.2.camel@lb-tlvb-dmitry>
References: <20110829161907.19232776e65389dea1caa7e8@canb.auug.org.au>
 <20110829132800.f7174f2e.rdunlap@xenotime.net>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Stephen Rothwell" <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Randy Dunlap" <rdunlap@xenotime.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110829132800.f7174f2e.rdunlap@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-08-29 at 13:28 -0700, Randy Dunlap wrote:
> On Mon, 29 Aug 2011 16:19:07 +1000 Stephen Rothwell wrote:
> 
> > Hi all,
> 
> (on i386 or x86_64)
> 
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:10148: error: 'bnx2x_fcoe_get_wwn' undeclared here (not in a function)
> 
> 
> Full randconfig file is attached.
> 
> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
This should sync #define structures between definition and declaration
---

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index f290b23..5b1f9b5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -522,7 +522,7 @@ void bnx2x_free_mem_bp(struct bnx2x *bp);
  */
 int bnx2x_change_mtu(struct net_device *dev, int new_mtu);
 
-#if defined(BCM_CNIC) && (defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE))
+#if defined(NETDEV_FCOE_WWNN) && defined(BCM_CNIC)
 /**
  * bnx2x_fcoe_get_wwn - return the requested WWN value for this port
  *
-- 
1.7.2.2
