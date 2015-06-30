From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH 1/1] igb: Use ARRAY_SIZE instead fo
	sizeof(a)/sizeof(a[0])
Date: Tue, 30 Jun 2015 14:53:05 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD653571921@ORSMSX114.amr.corp.intel.com>
References: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "pankaj.m@samsung.com" <pankaj.m@samsung.com>
To: Maninder Singh <maninder1.s@samsung.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15847 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752595AbbF3OxY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 10:53:24 -0400
In-Reply-To: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't see the reason this is needed so I'm going to say NAK.

Todd Fujinaka
Software Application Engineer
Networking Division (ND)
Intel Corporation
todd.fujinaka@intel.com
(503) 712-4565

-----Original Message-----
From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Maninder Singh
Sent: Monday, June 29, 2015 9:56 PM
To: Kirsher, Jeffrey T; Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald C; Vick, Matthew; Ronciak, John; Williams, Mitch A; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Cc: Maninder Singh; pankaj.m@samsung.com
Subject: [Intel-wired-lan] [PATCH 1/1] igb: Use ARRAY_SIZE instead fo sizeof(a)/sizeof(a[0])

Use ARRAY_SIZE instead fo sizeof(a)/sizeof(a[0])

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Reviewed-by: Yogesh Narayan Gaur <yn.gaur@samsung.com>
---
 drivers/net/ethernet/intel/igb/e1000_phy.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index c1bb64d..e399b3c 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -37,8 +37,7 @@ static s32  igb_set_master_slave_mode(struct e1000_hw *hw);  static const u16 e1000_m88_cable_length_table[] = {
 	0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };  #define M88E1000_CABLE_LENGTH_TABLE_SIZE \
-	(sizeof(e1000_m88_cable_length_table) / \
-	sizeof(e1000_m88_cable_length_table[0]))
+	ARRAY_SIZE(e1000_m88_cable_length_table)
 
 static const u16 e1000_igp_2_cable_length_table[] = {
 	0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21, @@ -50,8 +49,7 @@ static const u16 e1000_igp_2_cable_length_table[] = {
 	83, 89, 95, 100, 105, 109, 113, 116, 119, 122, 124,
 	104, 109, 114, 118, 121, 124};
 #define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
-	(sizeof(e1000_igp_2_cable_length_table) / \
-	 sizeof(e1000_igp_2_cable_length_table[0]))
+	ARRAY_SIZE(e1000_igp_2_cable_length_table)
 
 /**
  *  igb_check_reset_block - Check if PHY reset is blocked
--
1.7.9.5

_______________________________________________
Intel-wired-lan mailing list
Intel-wired-lan@lists.osuosl.org
http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
