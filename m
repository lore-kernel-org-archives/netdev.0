From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Please pull bug-fixes branch of linux-2.6-mv643xx_eth.git
Date: Tue, 23 Oct 2007 14:13:18 -0700
Message-ID: <20071023211317.GA29226@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:49518 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754630AbXJWVNT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 17:13:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The following changes since commit e8b8c977734193adedf2b0f607d6252c78e86394:
  Linus Torvalds (1):
        Revert "kconfig: tristate choices with mixed tristate and boolean values"

are available in the git repository at:

  git://farnsworth.org/dale/linux-2.6-mv643xx_eth.git bug-fixes

Dale Farnsworth (1):
      mv643xx_eth: Hook up mv643xx_get_sset_count

 drivers/net/mv643xx_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

It may be also viewed at:
http://www.farnsworth.org/git?p=dale/linux-2.6-mv643xx_eth.git;a=shortlog;h=bug-fixes

Thanks,
-Dale

Here is the single commit:

Author: Dale Farnsworth <dale@farnsworth.org>
Date:   Sat Oct 20 12:16:27 2007 -0700

    mv643xx_eth: Hook up mv643xx_get_sset_count
    
    Commit b9f2c044 replaced mv643xx_get_stats_count() with
    mv643xx_get_sset_count(), but forgot to hook it up.
    
    drivers/net/mv643xx_eth.c:2678: warning: mv643xx_get_sset_count defined but not used
    
    Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 84f2d63..54e4828 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2742,6 +2742,7 @@ static const struct ethtool_ops mv643xx_ethtool_ops = {
 	.get_drvinfo            = mv643xx_get_drvinfo,
 	.get_link               = mv643xx_eth_get_link,
 	.set_sg			= ethtool_op_set_sg,
+	.get_sset_count		= mv643xx_get_sset_count,
 	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
 	.get_strings            = mv643xx_get_strings,
 	.nway_reset		= mv643xx_eth_nway_restart,
