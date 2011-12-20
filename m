From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH net-next v2] igb: reset PHY after recovering from PHY
 power down
Date: Tue, 20 Dec 2011 16:05:53 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B626010891@ORSMSX102.amr.corp.intel.com>
References: <4EEE9248.8020009@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:21220 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751611Ab1LTQF5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 11:05:57 -0500
In-Reply-To: <4EEE9248.8020009@jp.fujitsu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Koki Sanagi [mailto:sanagi.koki@jp.fujitsu.com]
>Sent: Sunday, December 18, 2011 5:24 PM
>To: netdev@vger.kernel.org
>Cc: davem@davemloft.net; e1000-devel@lists.sourceforge.net; Wyborny,
>Carolyn; Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
>Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P; Duyck,
>Alexander H; Ronciak, John
>Subject: [PATCH net-next v2] igb: reset PHY after recovering from PHY
>power down
>
>According to 82576_Datasheet.pdf, PHY setting is lost after PHY power
>down.
>So resetting PHY is needed when recovering from PHY power down to set a
>default
>setting to PHY register.
>Owing to this lack, NIC doesn't link up in some rare situation.
>
>Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
>---
>diff --git a/drivers/net/ethernet/intel/igb/igb_main.c
>b/drivers/net/ethernet/intel/igb/igb_main.c
>index 89d576c..9b923b0 100644
>--- a/drivers/net/ethernet/intel/igb/igb_main.c
>+++ b/drivers/net/ethernet/intel/igb/igb_main.c
>@@ -1498,6 +1498,7 @@ void igb_power_up_link(struct igb_adapter
>*adapter)
> 		igb_power_up_phy_copper(&adapter->hw);
> 	else
> 		igb_power_up_serdes_link_82575(&adapter->hw);
>+	igb_reset_phy(&adapter->hw);
> }
>
> /**

ACK


Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
