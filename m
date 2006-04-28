From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] bcm43xx_d80211: fix bug in open
Date: Fri, 28 Apr 2006 17:45:49 +0200
Message-ID: <20060428174549.5480ed9a@griffin.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
	<200604212252.08325.mb@bu3sch.de>
	<20060421225210.36a0225b@griffin.suse.cz>
	<20060426193907.GB7922@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10417 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1030440AbWD1Ppv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 11:45:51 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060426193907.GB7922@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Apr 2006 15:39:12 -0400, John W. Linville wrote:
> Hacky or not, I'm applying this patch to keep the bcm43xx driver
> from breaking.  I don't suppose you have a patch for the rt2x00 driver?

The patch for bcm43xx was really just quick fix, only partially
tested...

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -4172,7 +4172,7 @@ static int bcm43xx_net_open(struct net_d
 	int res;
 
 	res = bcm43xx_init_board(bcm);
-	if (!res)
+	if (res)
 		return res;
 	bcm43xx_set_iwmode(bcm, bcm->iw_mode);
 	return 0;


-- 
Jiri Benc
SUSE Labs
