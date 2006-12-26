From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'r8169-upstream-fixes-20061226-00' tag
Date: Tue, 26 Dec 2006 23:31:59 +0100
Message-ID: <20061226223159.GA21314@electric-eye.fr.zoreil.com>
References: <20061223164911.GA16360@electric-eye.fr.zoreil.com> <459195A1.2010907@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36439 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932825AbWLZWew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 17:34:52 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <459195A1.2010907@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from tag 'r8169-upstream-fixes-20061226-00' in repository

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git tag r8169-upstream-fixes-20061226-00

to get the changes below.

Distance from 'netdev-2.6-upstream-fixes'
-----------------------------------------

81f4e6c190a0fa016fd7eecaf76a5f95d121afc2
87046e5062c483820f20c1fa6ed0826bb38fd4f0 <- netdev-2.6-upstream-fixes

Diffstat
--------

 drivers/net/r8169.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

Shortlog
--------

Francois Romieu:
      r8169: extraneous Cmd{Tx/Rx}Enb write

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1489100..577babd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1882,7 +1882,6 @@ static void rtl8169_hw_start(struct net_
 	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
 	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
-		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 		rtl8169_set_rx_tx_config_registers(tp);
 
 	cmd = RTL_R16(CPlusCmd);
-- 
Ueimor
