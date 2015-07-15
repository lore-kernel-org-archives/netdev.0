From: Corcodel Marian <corcodel.marian@gmail.com>
Subject: [PATCH net-next]r8169:Remove SYSErr bit add FEmp bit and more on
 RTL_CFG_2
Date: Wed, 15 Jul 2015 10:22:29 +0300
Message-ID: <20150715072229.GA3749@192-168-0-3.rdsnet.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36266 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbbGOHWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 03:22:33 -0400
Received: by widjy10 with SMTP id jy10so119858542wid.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 00:22:32 -0700 (PDT)
Received: from 192-168-0-3 (5-14-229-57.residential.rdsnet.ro. [5.14.229.57])
        by smtp.gmail.com with ESMTPSA id uo6sm6420130wjc.1.2015.07.15.00.22.30
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Jul 2015 00:22:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------mine-boundary-string
Content-Type: text/plain; charset=UTF-8; format=fixed
Content-Transfer-Encoding: 8bit


Add new bit interrupt FEmp, on RTL_CFG_2 bit SYSErr is reserved and add
 rests  bits.
 Committer: Corcodel Marian <corcodel.marian@gmail.com>

 On branch master
 Your branch is ahead of 'origin/master' by 15 commits.
   (use "git push" to publish your local commits)

 Changes to be committed:
	modified:   drivers/net/ethernet/realtek/r8169.c

Signed-off-by: Corcodel Marian <asu@192-168-0-3.rdsnet.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)


--------------mine-boundary-string
Content-Type: text/x-patch; name="0001-Signed-off-by-Corcodel-Marian-corcodel.marian-gmail..patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="0001-Signed-off-by-Corcodel-Marian-corcodel.marian-gmail..patch"

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index be67873..fc14a08 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -515,6 +515,7 @@ enum rtl_register_content {
 	/* InterruptStatusBits */
 	SYSErr		= 0x8000,
 	PCSTimeout	= 0x4000,
+	FEmp		= 0x0200,
 	SWInt		= 0x0100,
 	TxDescUnavail	= 0x0080,
 	RxFIFOOver	= 0x0040,
@@ -7962,8 +7963,8 @@ static const struct rtl_cfg_info {
 		.hw_start	= rtl_hw_start_8101,
 		.region		= 2,
 		.align		= 8,
-		.event_slow	= SYSErr | LinkChg | RxOverflow | RxFIFOOver |
-				  PCSTimeout,
+		.event_slow	= LinkChg | RxOverflow | RxFIFOOver |
+				  PCSTimeout | FEmp | SWInt | TxDescUnavail,
 		.features	= RTL_FEATURE_MSI,
 		.default_ver	= RTL_GIGA_MAC_VER_13,
 	}

--------------mine-boundary-string--
